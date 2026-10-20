{
  docker-nixpkgs,
  gawkInteractive,
  curl,
  wget,
  jq,
  zstd,
  zip,
  unzip,
  nodejs-slim,
  python3,
  python3Packages,
}:
(docker-nixpkgs.nix-flakes.override {
  # https://github.com/catthehacker/docker_images/blob/master/linux/ubuntu/scripts/act.sh#L46-L65
  # Ommitted sudo and gnupg-agent, not sure if they would work
  extraContents = [
    gawkInteractive
    curl
    wget
    jq
    zstd
    zip
    unzip
    nodejs-slim
    python3
    python3Packages.pip
    python3Packages.pipx
  ];
}).overrideAttrs
  (prev: {
    meta = (prev.meta or { }) // {
      description = "Nix runner image for GitHub/Gitea/Forgejo actions similar to `ghcr.io/catthehacker/ubuntu:act-latest`";
    };
  })
