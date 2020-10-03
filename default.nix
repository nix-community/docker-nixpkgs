{}:
let
  inherit (import ./nix) pkgs;
  inherit (pkgs) lib;

in {
  inherit pkgs;

  devShell = pkgs.mkShell {
    buildInputs = [
      pkgs.skopeo
      pkgs.jq
      pkgs.gnused
    ];
  };
}
