{ docker-nixpkgs
, cachix
}:
(docker-nixpkgs.nix-flakes.override {
  extraContents = [ cachix ];
}).overrideAttrs (prev: {
  meta = (prev.meta or { }) // {
    description = "Nix and Cachix image";
  };
})
