# A fat and modifiable Nix image
{ dockerTools
, bashInteractive
, cacert
, closureInfo
, coreutils
, curl
, direnv
, flakeParameters
, gcc-unwrapped
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
, stdenv
, xz
, mkUserEnvironment
}:
let
  channel = flakeParameters.nixpkgsChannel;

  # generate a user profile for the image
  profile = mkUserEnvironment {
    derivations = [
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

      # for the vscode extension

      # HACK: don't include the "libgcc" output. It has overlapping files with
      #       the "lib" output, and that breaks the build.
      (gcc-unwrapped // {
        outputs = builtins.filter (x: x != "libgcc") gcc-unwrapped.outputs;
      })
      iproute
    ];
  };

  image = dockerTools.buildImage {
    name = "devcontainer";

    # contents = [ ];

    extraCommands = ''
      # create the Nix DB
      export NIX_REMOTE=local?root=$PWD
      export USER=nobody
      ${nix}/bin/nix-store --load-db < ${closureInfo { rootPaths = [ profile ]; }}/registration

      # set the user profile
      ${profile}/bin/nix-env --profile nix/var/nix/profiles/default --set ${profile}

      # minimal
      mkdir -p bin usr/bin
      ln -s /nix/var/nix/profiles/default/bin/sh bin/sh
      ln -s /nix/var/nix/profiles/default/bin/env usr/bin/env

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
    '' + (if stdenv.hostPlatform.isAarch64 then ''
      # ld-linux-aarch64.so.1 is needed by vscode-server's in arm architecture
      mkdir -p lib
      ln -s "${glibc}/lib/ld-linux-aarch64.so.1" lib/ld-linux-aarch64.so.1
      ln -s "${glibc}/lib/ld-linux-aarch64.so.1" lib/ld-linux.so.1
      ln -sf "${stdenv.cc.cc.lib}/lib/libstdc++.so.6" lib/libstdc++.so.6
    '' else ""
      ) + (if stdenv.hostPlatform.isx86_64 then ''
      # allow ubuntu ELF binaries to run. VSCode copies it's own.
      mkdir -p lib64
      ln -s ${glibc}/lib64/ld-linux-x86-64.so.2 lib64/ld-linux-x86-64.so.2
      # ld-linux-x86-64.so.2 is needed by vscode-server's nodejs in case it install 32 bit nodejs
      ln -s "${glibc}/lib64/ld-linux-x86-64.so.2" lib64/ld-linux.so.2
      ln -sf "${stdenv.cc.cc.lib}/lib64/libstdc++.so.6" lib64/libstdc++.so.6
    '' else ""
      );

    config = {
      Cmd = [ "/nix/var/nix/profiles/default/bin/bash" ];
      Env = [
        "ENV=/nix/var/nix/profiles/default/etc/profile.d/nix.sh"
        "GIT_SSL_CAINFO=/nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt"
        "LD_LIBRARY_PATH=/nix/var/nix/profiles/default/lib"
        "PAGER=less"
        "PATH=/nix/var/nix/profiles/default/bin"
        "SSL_CERT_FILE=/nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt"
        (
          if channel != "" then
            "NIX_PATH=nixpkgs=channel:${channel}"
          else
            "NIX_PATH=nixpkgs=${../nix/fake_nixpkgs}"
        )
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
