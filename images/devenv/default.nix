{ docker-nixpkgs
, devenv ? null
}:
(docker-nixpkgs.nix.override {
  # only available since 24.05
  extraContents = if devenv == null then [] else [ devenv ];
}).overrideAttrs (prev: {
  meta = (prev.meta or { }) // {
    description = "Nix and devenv image";
  };
})
