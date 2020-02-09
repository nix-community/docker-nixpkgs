let
  nixpkgs = builtins.fetchTarball "channel:nixos-19.09";
  pkgs = import nixpkgs { config = {}; overlays = []; };
in
with pkgs;
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
