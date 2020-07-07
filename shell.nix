let
  nixpkgs = builtins.fetchTarball "channel:nixos-20.03";
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
