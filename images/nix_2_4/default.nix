{ docker-nixpkgs
, nix_2_4
, writeTextFile
}:
docker-nixpkgs.nix.override {
  nix = nix_2_4;
  extraContents = [
    (writeTextFile {
      name = "nix.conf";
      destination = "/etc/nix/nix.conf";
      text = ''
        experimental-features = nix-command flakes
      '';
    })
  ];
}

