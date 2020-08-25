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
    { nixHash ? null }:
    pkgs.callPackage ./image.nix {
      inherit nixpkgs nixHash;
    }
  ) sources;

in {
  # TODO: direnv
  devShell = pkgs.mkShell {
    buildInputs = [
      pkgs.niv
    ];
  };
  inherit updater pkgs sources images;
}
