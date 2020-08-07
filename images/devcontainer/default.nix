# A fat and modifiable Nix image
{ stdenv
, dockerTools
, bashInteractive
, cacert
, closureInfo
, coreutils
, curl
, direnv
, gitReallyMinimal
, glibc
, gnugrep
, gnused
, gnutar
, gzip
, iana-etc
, iproute
, less
, lib
, nix
, openssh
, procps
, shadow
, sudo
, xz
, patchelf
, mkUserEnvironment
, writeScriptBin
}:
let
  channel = builtins.getEnv("NIXPKGS_CHANNEL");

  /**
    This entrypoint patches node binary copied by vscode. This always succeeds
    as vscode is always slower to run node, as our entrypoint to patch it.

    This solution is prefered to LD_LIBRARY_PATH, as setting LD_LIBRARY_PATH
    globally messes environment, as libraries found this way will always have
    priority. Only other other alternative i can think of to patch node is to
    have a LD_PRELOAD set with that returns the right libraries, but that
    solution even if it is more clean can present more runtime issues.
  **/
  entrypoint = writeScriptBin "entrypoint.sh" ''
    #!${bashInteractive}/bin/bash -e

    until ${patchelf}/bin/patchelf \
      --set-rpath "${stdenv.cc.cc.lib}/lib" \
      --set-interpreter "${glibc}/lib64/ld-linux-x86-64.so.2" \
      $HOME/.vscode-server/bin/*/node 2>/dev/null; do true; done

    echo "vscode server binaries successfully patched"

    "$@"
  '';

  # generate a user profile for the image
  profile = mkUserEnvironment {
    derivations = [
      # container entrypoint
      entrypoint

      # core utils
      coreutils
      procps
      gnugrep
      gnused
      less

      # add /bin/sh
      bashInteractive
      nix

      # runtime dependencies of nix
      cacert
      gitReallyMinimal
      gnutar
      gzip
      xz

      # for haskell binaries
      iana-etc

      # for user management
      shadow
      sudo

      # for the vscode extension
      iproute
    ];
  };

  image = dockerTools.buildImage {
    name = "devcontainer";

    contents = [ ];

    extraCommands = ''
      # create the Nix DB
      export NIX_REMOTE=local?root=$PWD
      export USER=nobody
      ${nix}/bin/nix-store --load-db < ${closureInfo { rootPaths = [ profile ]; }}/registration

      # set default profile
      ${profile}/bin/nix-env --profile nix/var/nix/profiles/default --set ${profile}

      # minimal
      mkdir -p bin usr/bin
      ln -s /nix/var/nix/profiles/default/bin/sh bin/sh
      ln -s /nix/var/nix/profiles/default/bin/env usr/bin/env

      # install sudo
      mkdir -p usr/bin usr/lib/sudo
      cp ${sudo}/bin/sudo usr/bin/sudo
      cp -r ${sudo}/libexec/sudo/* usr/lib/sudo

      # might as well...
      ln -s /nix/var/nix/profiles/default/bin/bash bin/bash

      # setup shadow, bashrc
      mkdir home
      cp -r ${./root/etc} etc
      chmod +w etc etc/group etc/passwd etc/shadow

      # setup iana-etc for haskell binaries
      ln -s /nix/var/nix/profiles/default/etc/protocols etc/protocols
      ln -s /nix/var/nix/profiles/default/etc/services etc/services

      # make sure /tmp exists
      mkdir -m 0777 tmp

      # VSCode assumes that /sbin/ip exists
      mkdir sbin
      ln -s /nix/var/nix/profiles/default/bin/ip sbin/ip
    '';

    config = {
      Entrypoint = [ "/nix/var/nix/profiles/default/bin/entrypoint.sh" ];
      Cmd = [ "sleep" "infinity" ];
      Env = [
        "ENV=/nix/var/nix/profiles/default/etc/profile.d/nix.sh"
        "GIT_SSL_CAINFO=/nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt"
        "PAGER=less"
        "PATH=/usr/bin:/nix/var/nix/profiles/default/bin"
        "SSL_CERT_FILE=/nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt"
        (
          if channel != "" then
            "NIX_PATH=nixpkgs=channel:${channel}"
          else
            "NIX_PATH=nixpkgs=${../nix/fake_nixpkgs}"
        )
      ];

      # commands to run before build of every Dockerfile using this image
      OnBuild = [
        # fix permissions of sudo and set suid bit
        "RUN chmod -R u+s,u+rx,g+x,o+x /usr/bin/sudo && chown -R root:root /usr/lib/sudo"

        # expose USERNAME, USER_UID, USER_GID as build arguments
        "ARG USERNAME=vscode"
        "ARG USER_UID=1000"
        "ARG USER_GID=$USER_UID"

        # add user and group, add user to wheel group
        "RUN groupadd -f -g $USER_GID $USERNAME && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -G wheel -m $USERNAME"

        # fix permissions of nix store
        "RUN chown -R $USER_UID:$USER_GID /nix"

        # change user, change workdir and create user profile
        "USER $USERNAME"
        "WORKDIR /home/$USERNAME"
        "RUN nix-env --profile /nix/var/nix/profiles/per-user/$USERNAME/profile -iA"
        "ENV USER=$USERNAME"
        "ENV PATH=/usr/bin:/nix/var/nix/profiles/per-user/$USERNAME/profile/bin:/nix/var/nix/profiles/default/bin"
      ];
      Labels = {
        # https://github.com/microscaling/microscaling/blob/55a2d7b91ce7513e07f8b1fd91bbed8df59aed5a/Dockerfile#L22-L33
        "org.label-schema.vcs-ref" = "master";
        "org.label-schema.vcs-url" = "https://github.com/nix-community/docker-nixpkgs";
      };
    };
  };
in
image // {
  meta = image.meta // {
    description = "Nix devcontainer for VSCode";
  };
}
