{ docker-nixpkgs
, nixFlakes
, writeTextFile
, extraContents ? [ ]
}:
docker-nixpkgs.nix.override {
  nix = nixFlakes;
  extraContents = [
    (writeTextFile {
      name = "nix.conf";
      destination = "/etc/nix/nix.conf";
      text = ''
        experimental-features = nix-command flakes
      '';
    })
  ] ++ extraContents;
}
