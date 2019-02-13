#!/usr/bin/env bash
#
# Travis CI specific build script
#
set -euo pipefail

./build

# default to Docker Hub
: "${REGISTRY:=docker.io}"
: "${IMAGE_PREFIX:=nixpkgs}"

# IMAGE_TAG is provided by .travis.yml

# the user has to set REGISTRY_USER and REGISTRY_PASSWORD

if [[ "$TRAVIS_BRANCH" = master && -z "$TRAVIS_PULL_REQUEST_BRANCH" ]]; then
  ./docker-login "$REGISTRY_USER" "$REGISTRY_PASSWORD" "$REGISTRY"
  ./push-all "$REGISTRY" "$IMAGE_PREFIX" "$IMAGE_TAG"
  if [[ $REGISTRY = *docker.io ]]; then
    ./update-dockerhub "$REGISTRY_USER" "$REGISTRY_PASSWORD" "$IMAGE_PREFIX"
  fi
else
  echo "=== not pushing on non-master ==="
fi
