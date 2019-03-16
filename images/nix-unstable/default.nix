{ docker-nixpkgs
, nixUnstable
}:
docker-nixpkgs.nix.override {
  nix = nixUnstable;
}
