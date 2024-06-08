{ docker-nixpkgs
, pkgs
, nixUnstable
}:
docker-nixpkgs.nix.override {
  nix = pkgs.nixVersions.latest or pkgs.nixUnstable;
}
