{}:
let
  inherit (import ./nix) pkgs sources;
  inherit (pkgs) lib;

  image-updater = pkgs.writeShellScriptBin "update" ''
    export PATH=${lib.makeBinPath [ pkgs.skopeo pkgs.jq ]}:$PATH
    ${lib.concatMapStringsSep "\n" (attr:
      let nixpkgs = sources.${attr}; in ''
        ATTR=${attr} TAG=${nixpkgs.rev} ${./image-update}
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
      inherit attr nixHash;
      rev = nixpkgs.rev;
    }
  ) sources;

  nixpkgs-updater = pkgs.writeShellScriptBin "update" ''
    export PATH=${lib.makeBinPath [ pkgs.niv pkgs.gnused pkgs.jq ]}:$PATH

    echo "Updating niv nixpkgs sources.." >&2
    niv update

    echo "Updating tests.." >&2
    ${toString ./tests/update-tests}
  '';

in {
  devShell = pkgs.mkShell {
    buildInputs = [
      pkgs.niv
      pkgs.jq
      pkgs.gnused
    ];
  };
  inherit pkgs sources image-updater images nixpkgs-updater;

  tests = import ./tests { inherit pkgs; };
}
