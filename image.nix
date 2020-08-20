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
}:
let

  exportProfile = pkgs.writeShellScriptBin "export-profile" ''
    set -xe
    profile=''${1:-~/.nix-profile}
    profile=$(realpath "$profile")
    root=''${2:-/root}

    nix-store --export $(nix-store -qR "$profile") | \
      NIX_REMOTE=local?root="$root" nix-store --import
    ln -s -t "$root" "$profile"/*
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
    pkgs.ncdu
  ];
in
dockerTools.buildImage {
  name = "nixpkgs-${nixpkgs.branch}";
  tag = nixpkgs.rev;
  contents = envContents;

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

    # for /usr/bin/env
    mkdir usr
    ln -s ../bin usr/bin

    # make sure /tmp exists
    mkdir -m 1777 tmp
  '';

  config = {
    Cmd = [ "/bin/bash" ];
    Env = [
      "ENV=/etc/profile.d/nix.sh"
      "BASH_ENV=/etc/profile.d/nix.sh"
      "NIX_BUILD_SHELL=/bin/bash"
      "NIX_PATH=nixpkgs=${nixpkgs}"
      "PAGER=cat"
      "PATH=/nix/var/nix/profiles/default/bin:/bin/usr/bin:/bin"
      "SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt"
      "USER=root"
    ];
  };
}
