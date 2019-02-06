{ channel ? "nixos-unstable" }@args:
with import ./. args;
mkShell {
  buildInputs = [
    jq
    skopeo
  ];

  shellHook = ''
    # try to work aroud build issues
    unset TMPDIR
  '';
}
