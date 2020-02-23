{ docker-nixpkgs
, cachix
}:
(docker-nixpkgs.nix.override {
  extraContents = [ cachix ];
}).overrideAttrs (prev: {
  meta = prev.meta // {
    description = "Nix and Cachix image";
  };
})
