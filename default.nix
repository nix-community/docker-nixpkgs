{}:
let
  inherit (import ./nix) pkgs sources;
  inherit (pkgs) lib;


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
      inherit nixHash;
    }
  ) sources;

  imageUpdater = pkgs.writeShellScript "update" (lib.concatStringsSep "\n"
    (lib.mapAttrsToList (attr: nixpkgs: ''
      ${pkgs.scripts.image-update} \
        ${toString ./.} ${attr} ${nixpkgs.rev}
    '') sources));

  testRunner = pkgs.writeShellScript "test-runner" (lib.concatStringsSep "\n"
    (lib.mapAttrsToList (attr: nixpkgs: ''
      ${pkgs.scripts.run-tests} \
        ${toString ./.} ${attr}
    '') sources));

  nixpkgsUpdater = pkgs.writeShellScript "update" ''
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
  inherit testRunner imageUpdater nixpkgsUpdater;

  # Needed for adding a new channel, used in shell.nix
  devShell = pkgs.mkShell {
    buildInputs = [ pkgs.niv ];
  };
}
