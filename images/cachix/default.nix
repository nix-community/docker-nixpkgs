{ docker-nixpkgs
, cachix
, nix
}:
(docker-nixpkgs.nix.override {
  nix = nix;
  extraContents = [ cachix gnugrep ];
}).overrideAttrs (prev: {
  meta = (prev.meta or {}) // {
    description = "Nix and Cachix image";
  };
})
