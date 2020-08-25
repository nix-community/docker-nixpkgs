{ nixpkgs
, dockerTools
, coreutils
, bashInteractive
, nix
, cacert
, gitReallyMinimal
, gnutar
, gzip
, openssh
, xz
, stdenv
, cachix
, shadow
, pkgs
, lib
, less
, gnugrep
, gnused
}:
let

  exportProfile = pkgs.writeShellScriptBin "export-profile" ''
    set -e
    root=$1
    # Same default profile as nix-env
    profile=$(realpath ''${NIX_PROFILE:-~/.nix-profile})

    if [[ -z "$1" ]]; then
      echo "Usage: export-profile [ROOTDIR]" >&2
      echo "  exports everything installed with nix-env to the given directory," >&2
      echo "  suitable as the root of the next stage in a multi-stage build." >&2
      exit 1
    elif [[ -e "$root" ]]; then
      echo "The directory given to export-profile needs to not exist already" >&2
      exit 1
    fi

    # Copy the profile directory to the new root, such that all the profiles
    # binaries in $profile/bin/* will be available as /bin/* in the new root
    #
    # Note that cp -Ls is used to replicate the directory structure of the
    # profile but use symlinks to point back to the files in the Nix store
    # This for one avoids the problem of Docker overriding /etc when starting
    echo "Copying $profile to $root" >&2
    mkdir -p "$(dirname "$root")"
    cp -R -Ls "$profile" "$root"

    # Remove the env manifest file as we don't need it
    rm "$root"/manifest.nix

    # We also need the profiles closure in the new root for all symlinks to be valid
    echo "Copying all the profiles Nix dependencies to $root" >&2
    nix-store --export $(nix-store -qR "$profile") | \
      NIX_REMOTE=local?root="$root" nix-store --import >/dev/null

    # nix-store --import also creates /nix/var, but we don't need this as Nix
    # won't be available in the final stage, so we only need the store
    rm -rf "$root/nix/var"

    echo "Finished Nix profile export to $root" >&2
  '';

  envContents = [
    exportProfile
    images/nix/root
    coreutils
    bashInteractive
    nix

    # runtime dependencies of nix
    cacert
    gitReallyMinimal
    gnutar
    gzip
    openssh
    xz

    cachix

    # Some utilities
    less
    gnugrep
    gnused
  ];
in
dockerTools.buildImage {
  name = "nixpkgs";

  # TODO: This is pretty nasty: It puts all files of these contents into / directly
  # Better do something like images/devcontainer, which only installs them into a profile directory,
  # keeping / clean like on NixOS
  contents = envContents;

  # This section is copied from https://github.com/NixOS/nixpkgs/blob/7a100ad9543687d046cfeeb5156dfaa697e1abbd/pkgs/build-support/docker/default.nix#L39-L57
  # but adjusted to support additional contents
  extraCommands = let
    contents = envContents ++ [
      nixpkgs
    ];
  in ''
    echo "Generating the nix database..."
    echo "Warning: only the database of the deepest Nix layer is loaded."
    echo "         If you want to use nix commands in the container, it would"
    echo "         be better to only have one layer that contains a nix store."

    export NIX_REMOTE=local?root=$PWD
    # A user is required by nix
    # https://github.com/NixOS/nix/blob/9348f9291e5d9e4ba3c4347ea1b235640f54fd79/src/libutil/util.cc#L478
    export USER=nobody
    ${nix}/bin/nix-store --load-db < ${pkgs.closureInfo {rootPaths = contents;}}/registration

    mkdir -p nix/var/nix/gcroots/docker/
    for i in ${lib.concatStringsSep " " contents}; do
      ln -s $i nix/var/nix/gcroots/docker/$(basename $i)
    done;

    mkdir -p usr/bin
    ln -s ../bin/env usr/bin/env

    # make sure /tmp exists
    mkdir -m 1777 tmp
  '';

  config = {
    Cmd = [ "/bin/bash" ];
    WorkingDir = "/root";
    Env = [
      # So that nix-shell doesn't fetch its own bash
      "NIX_BUILD_SHELL=/bin/bash"
      # The image itself pins nixpkgs, expose this for convenience
      "NIX_PATH=nixpkgs=${nixpkgs}"
      # Make nix-env installs work
      "PATH=/nix/var/nix/profiles/default/bin:/bin"
      # Needed for curl and co.
      "NIX_SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt"
      # Docker apparently doesn't set this
      "USER=root"
    ];
  };
}
