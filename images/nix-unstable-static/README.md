# nix-unstable-static

This is a special variant of the nix image that contains no `/nix/store`.
Instead, nix and all the supporting binaries are statically built and copied
into /bin.

The main use-case is to be able to run nix in the container, but share the
`/nix/store` with the host.
