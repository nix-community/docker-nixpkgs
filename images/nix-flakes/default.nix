{ docker-nixpkgs
, nixVersions
, writeTextFile
, extraContents ? [ ]
}:
docker-nixpkgs.nix.override {
  nix = nixVersions.stable;
  extraContents = [
    (writeTextFile {
      name = "nix.conf";
      destination = "/etc/nix/nix.conf";
      text = ''
        accept-flake-config = true
        experimental-features = nix-command flakes
        max-jobs = auto
      '';
    })
  ] ++ extraContents;

  extraEnv = [
    "PATH=/root/.nix-profile/bin:/usr/bin:/bin" # Not sure how to just prepend
  ];
}
