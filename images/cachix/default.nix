{ docker-nixpkgs
, cachix
}:
(docker-nixpkgs.nix.override {
  extraContents = [ cachix ];
}).overrideAttrs (prev: {
  meta = (prev.meta or { }) // {
    description = "Nix and Cachix image";
  };
})
