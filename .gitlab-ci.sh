#!/usr/bin/env bash
#
# Gitlab CI specific build script.
#
set -euo pipefail

./build

# default to the Gitlab registry
: "${REGISTRY:=$CI_REGISTRY}"
: "${REGISTRY_USER:=$CI_REGISTRY_USER}"
: "${REGISTRY_PASSWORD:=$CI_REGISTRY_PASSWORD}"
: "${IMAGE_PREFIX:=$CI_PROJECT_PATH}"

# IMAGE_TAG is provided by .gitlab-ci.yml


if [[ "$CI_COMMIT_REF_NAME" = master ]]; then
  ./docker-login "$REGISTRY_USER" "$REGISTRY_PASSWORD" "$REGISTRY"
  ./push-all "$REGISTRY" "$IMAGE_PREFIX" "$IMAGE_TAG"
  if [[ $REGISTRY = *docker.io ]]; then
    ./dockerhub-metadata "$REGISTRY_USER" "$REGISTRY_PASSWORD" "$IMAGE_PREFIX"
  fi
else
  echo "=== not pushing on non-master ==="
fi
