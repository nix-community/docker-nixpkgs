#!/usr/bin/env bash
#
# Travis CI specific build script
#
set -euo pipefail

./build

# default to Docker Hub
# the user has to set REGISTRY_USER and REGISTRY_PASSWORD
: "${REGISTRY:=docker.io}"
: "${IMAGE_PREFIX:=nixpkgs}"

# either pass those two or set the NIXPKGS_CHANNEL
: "${IMAGE_TAG:=$NIXPKGS_CHANNEL}"
: "${NIX_PATH:=nixpkgs=channel:$NIXPKGS_CHANNEL}"
export NIX_PATH

if [[ "$TRAVIS_BRANCH" = master && -z "$TRAVIS_PULL_REQUEST_BRANCH" ]]; then
  ./docker-login "$REGISTRY_USER" "$REGISTRY_PASSWORD" "$REGISTRY"
  ./push-all "$REGISTRY" "$IMAGE_PREFIX" "$IMAGE_TAG"
  if [[ $REGISTRY = *docker.io ]]; then
    ./dockerhub-metadata "$REGISTRY_USER" "$REGISTRY_PASSWORD" "$IMAGE_PREFIX"
  fi
else
  echo "=== not pushing on non-master ==="
fi
