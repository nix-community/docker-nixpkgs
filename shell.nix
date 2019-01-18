{ channel ? "nixos-unstable" }@args:
with import ./. args;
mkShell {
  buildInputs = [
    jq
    skopeo
  ];
}
