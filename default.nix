{}:
let
  inherit (import ./nix) pkgs sources;
  inherit (pkgs) lib;

  imageUpdater = pkgs.writeShellScriptBin "update" (lib.concatStringsSep "\n"
    (lib.mapAttrsToList (attr: nixpkgs: ''
      ATTR=${attr} TAG=${nixpkgs.rev} \
        ${pkgs.scripts.singleImageUpdater}/bin/update
    '') sources));

  images = lib.mapAttrs (attr: nixpkgs:
    # Allows specifying --argstr nixHash on the CLI
    { nixHash ? null }:
    let
      # All the images dependencies should come from the nixpkgs it's built for
      pkgs = import nixpkgs {
        overlays = [ (import ./overlay.nix) ];
        config = {};
      };
    in pkgs.callPackage ./image.nix {
      nixpkgs = fetchTarball {
        name = "nixpkgs-src";
        inherit (nixpkgs) url sha256;
      };
      inherit attr nixHash;
      rev = nixpkgs.rev;
    }
  ) sources;

  nixpkgsUpdater = pkgs.writeShellScriptBin "update" ''
    export PATH=${lib.makeBinPath [ pkgs.niv pkgs.gnused pkgs.jq ]}:$PATH

    echo "Updating niv nixpkgs sources.." >&2
    niv update

    echo "Updating tests.." >&2
    ${toString ./tests/update-tests}
  '';

in {
  # For debugging/introspection
  inherit pkgs sources;

  # For building the images
  inherit images;

  # Updaters for CI
  inherit nixpkgsUpdater imageUpdater;

  # Needed if adding a new channel
  devShell = pkgs.mkShell {
    buildInputs = [ pkgs.niv ];
  };
}
