let
  sources = import nix/sources.nix;
  nixpkgs = sources.nixpkgs;
in import sources.nixpkgs {
  overlays = [];
  config = {};
}
