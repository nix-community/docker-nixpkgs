{}:
let
  inherit (import ./nix) pkgs sources;
  inherit (pkgs) lib;

  updater = pkgs.writeShellScriptBin "update" ''
    export PATH=${lib.makeBinPath [ pkgs.skopeo pkgs.jq ]}:$PATH
    ${lib.concatMapStringsSep "\n" (attr:
      let nixpkgs = sources.${attr}; in ''
        ATTR=${attr} TAG=${nixpkgs.rev} ${./update}
      ''
    ) (lib.attrNames sources)}
  '';

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

in {
  devShell = pkgs.mkShell {
    buildInputs = [ pkgs.niv ];
  };
  inherit pkgs sources updater images;
}
