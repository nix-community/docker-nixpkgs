let
  sources = import ./sources.nix;
  internal = sources {
    sourcesFile = ./internal.json;
  };
  pkgs = import internal.nixpkgs {
    config = {};
    overlays = [ (import ../overlay.nix) ];
  };
in {
  inherit pkgs;
  sources = removeAttrs sources [ "__functor" ];
}
