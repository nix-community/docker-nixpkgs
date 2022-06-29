#!/usr/bin/env bash
#
# Run nixpkgs/nix-unstable-static as the current user and the host /nix/store.
#
# Usage: docker-nix-user.sh [<command> ...<args>]
#
set -euo pipefail

image=nixpkgs/nix-unstable-static

options=(
  -ti
  # Remove the container on exit
  --rm
  -e NIX_PATH="nixpkgs=channel:nixos-22.05"
  # Used by /run_as_user.sh
  -e user_id="$(id -u)"
  -e user_name="$(id -nu)"
  -e group_id="$(id -g)"
  -e group_name="$(id -ng)"
  # Use the host store
  -v /nix:/nix
  # Mount the code into the container
  -v "$PWD:/workspace"
  -w /workspace
  --entrypoint /run_as_user.sh
)
exec docker run "${options[@]}" "$image" "$@"
