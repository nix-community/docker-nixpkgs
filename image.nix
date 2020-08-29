{ nixpkgs, nixHash }:
let
  pkgs = import nixpkgs {
    config = {};
    overlays = [ (import ./overlay.nix) ];
  };
  inherit (pkgs) lib;

  # TODO: This is pretty nasty: It puts all files of these contents into / directly
  # Better do something like images/devcontainer, which only installs them into a profile directory,
  # keeping / clean like on NixOS
  # Make sure to still keep /usr/bin/env and /bin/sh
  envContents = with pkgs; [
    # Custom things
    ./root-files
    scripts.exportProfile

    # Very basics
    coreutils
    bashInteractive

    # Nix and runtime dependencies of it
    nix
    cacert
    gitReallyMinimal
    gnutar
    gzip
    openssh
    xz

    # Extra tools
    cachix
  ];

  # The contents of the Nix database in the built container
  nixDbContents = envContents ++ [
    # We add nixpkgs only here because otherwise it would just spill its contents into /
    nixpkgs
  ];

  # This section is copied from https://github.com/NixOS/nixpkgs/blob/7a100ad9543687d046cfeeb5156dfaa697e1abbd/pkgs/build-support/docker/default.nix#L39-L57
  # but adjusted to support additional contents
  extraCommands = ''
    echo "Generating the nix database..."
    echo "Warning: only the database of the deepest Nix layer is loaded."
    echo "         If you want to use nix commands in the container, it would"
    echo "         be better to only have one layer that contains a nix store."

    export NIX_REMOTE=local?root=$PWD
    # A user is required by nix
    # https://github.com/NixOS/nix/blob/9348f9291e5d9e4ba3c4347ea1b235640f54fd79/src/libutil/util.cc#L478
    export USER=nobody
    ${pkgs.nix}/bin/nix-store --load-db < ${pkgs.closureInfo { rootPaths = nixDbContents; }}/registration

    mkdir -p nix/var/nix/gcroots/docker/
    for i in ${lib.concatStringsSep " " nixDbContents}; do
      ln -s $i nix/var/nix/gcroots/docker/$(basename $i)
    done;

    mkdir -p usr/bin
    ln -s ../bin/env usr/bin/env

    # make sure /tmp exists
    mkdir -m 1777 tmp
  '';
in pkgs.dockerTools.buildImage {
  name = "nixpkgs";
  # Doesn't make images have a creation date of 1970
  created = "now";

  contents = envContents;
  inherit extraCommands;

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
  } // lib.optionalAttrs (nixHash != null) {
    # Embed a nixHash into the image if given, allowing later extraction via skopeo inspect
    # By embedding such a hash, we can know whether a commit-specific image on
    # DockerHub needs to be updated after changes made to the image builder
    # See scripts/image-update for how this hash is generated
    Labels.NixHash = nixHash;
  };
}
