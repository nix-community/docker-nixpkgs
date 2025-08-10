{ docker-nixpkgs
, attic-client
}:
(docker-nixpkgs.nix.override {
  extraContents = [ attic-client ];
}).overrideAttrs (prev: {
  meta = (prev.meta or { }) // {
    description = "Nix and Attic client image";
  };
})
