{}:
let
  inherit (import ./nix) pkgs sources;
in {
  devShell = pkgs.mkShell {
    buildInputs = [
      pkgs.niv
    ];
  };

  inherit (pkgs) docker-nixpkgs;
  inherit pkgs;
  image = pkgs.callPackage ./image.nix {
    nixpkgs = sources.nixpkgs;
  };
}
#
#  pkgs = import 
#
#  nixpkgs = builtins.fetchTarball "channel:nixos-20.03";
#  pkgs = import nixpkgs { config = {}; overlays = []; };
#in
#with pkgs;
#mkShell {
#  buildInputs = [
#    jq
#    skopeo
#  ] ++ lib.optional (pkgs ? mdsh) pkgs.mdsh;
#
#  shellHook = ''
#    # try to work aroud build issues
#    unset TMPDIR
#  '';
#}
