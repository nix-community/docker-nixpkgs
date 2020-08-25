let
  pkgs = import (import ./sources.nix).nixpkgs {
    config = {};
    overlays = [ (import ../overlay.nix) ];
  };
  sources = import ./sources.nix {
    sourcesFile = ./nixpkgs-sources.json;
  };
in {
  inherit pkgs sources;
}
