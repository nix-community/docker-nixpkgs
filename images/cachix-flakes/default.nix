{ docker-nixpkgs
, nixFlakes
}:
docker-nixpkgs.cachix.override {
  nix = nixFlakes;
}
