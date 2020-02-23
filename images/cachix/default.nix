{ docker-nixpkgs
, cachix
}:
docker-nixpkgs.nix.override {
  extraContents = [ cachix ];
}
