#!/usr/bin/env bash
#
# CI specific build script.
#
set -euo pipefail

channel=${NIXPKGS_CHANNEL:-nixos-unstable}
registry=${CI_REGISTRY:-docker.io}
registry_auth=${CI_REGISTRY_AUTH:-}
image_prefix=${CI_PROJECT_PATH:-nixpkgs}
system_name=${NIX_SYSTEM_NAME:-x86_64-linux}

if [[ $channel == nixos-unstable ]]; then
  image_tag=latest
else
  image_tag=$channel
fi

export NIX_PATH=channel:$channel

banner() {
  echo "========================================================"
  echo "  $*"
  echo "========================================================"
}

cd "$(dirname "$0")"

banner "Building images"
# Build all the docker images
nix-build \
  --no-out-link \
  --option sandbox true \
  --argstr system "$system_name"

if [[ $(git rev-parse --abbrev-ref HEAD) != master ]]; then
  banner "Skipping push on non-master branch"
  exit
fi

if [[ -n "${registry_auth}" ]]; then
  banner "docker login"
  ./docker-login "$registry_auth" "$registry"
fi

banner "docker push"
./push-all "$registry" "$image_prefix" "$image_tag"

if [[ -n "${registry_auth}" && $registry = *docker.io ]]; then
  banner "docker metadata update"
  ./dockerhub-metadata "$registry_auth" "$image_prefix"
fi
