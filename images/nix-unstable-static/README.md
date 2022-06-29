# nix-unstable-static

This is a special variant of the nix image that contains no `/nix/store`.
Instead, nix and all the supporting binaries are statically built and copied
into /bin.

The main use-case is to be able to run nix in the container, but share the
`/nix/store` with the host.

## Using the container with the host store

This folder ships with a complementary script that you can use to run the
image as the current user and the host /nix/store.

Usage: `docker-nix-user.sh [<command> ...<args>]`

