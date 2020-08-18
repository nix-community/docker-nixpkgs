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
  image = pkgs.callPackage ./image.nix {
    nixpkgs = sources.nixpkgs;
  };
  empty = pkgs.callPackage ./empty.nix {};
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
