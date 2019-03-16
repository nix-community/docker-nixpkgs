_: pkgs: let
  importDir = import ./lib/importDir.nix {
    inherit (pkgs) lib; 
  };
in {
  # builder stuff can be in the top-level
  buildCLIImage = pkgs.callPackage ./lib/buildCLIImage.nix {};

  # docker images must be lower-cased
  docker-nixpkgs = importDir (path: pkgs.callPackage path {}) ./images;
}
