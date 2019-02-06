#!/usr/bin/env bash
#
# Travis CI specific build script
#
set -euo pipefail

./build

if [[ "$TRAVIS_BRANCH" = master && -z "$TRAVIS_PULL_REQUEST_BRANCH" ]]; then
  ./docker-login "$CI_REGISTRY" "$CI_REGISTRY_USER" "$CI_REGISTRY_PASSWORD"
  ./push-all "$CI_REGISTRY_PREFIX" "$IMAGE_TAG"
else
  echo "=== not pushing on non-master ==="
fi
