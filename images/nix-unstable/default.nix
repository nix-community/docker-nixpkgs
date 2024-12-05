{ docker-nixpkgs
, pkgs
}:
docker-nixpkgs.nix.override {
  nix = pkgs.nixVersions.latest;
}
