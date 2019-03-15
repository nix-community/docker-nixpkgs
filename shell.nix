{ nixpkgs ? <nixpkgs> }@args:
with import ./. args;
mkShell {
  buildInputs = [
    jq
    skopeo
  ] ++ lib.optional (pkgs ? mdsh) pkgs.mdsh;

  shellHook = ''
    # try to work aroud build issues
    unset TMPDIR
  '';
}
