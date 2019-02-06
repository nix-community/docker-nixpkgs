#!/usr/bin/env bash
#
# Gitlab CI specific build script.
#
set -euo pipefail

./build

if [[ "$CI_COMMIT_REF_NAME" = master ]]; then
  ./docker-login "$CI_REGISTRY" "$CI_REGISTRY_USER" "$CI_REGISTRY_PASSWORD"
  ./push-all "$CI_REGISTRY_IMAGE" "$IMAGE_TAG"
else
  echo "=== not pushing on non-master ==="
fi
