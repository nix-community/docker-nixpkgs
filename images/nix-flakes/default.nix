{ docker-nixpkgs
, nixFlakes
}:
docker-nixpkgs.nix.override {
  nix = nixFlakes;
}
