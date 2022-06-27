let
  nixpkgs = builtins.fetchTarball "channel:nixos-22.05";
  pkgs = import nixpkgs { config = { }; overlays = [ ]; };
in
with pkgs;
mkShell {
  buildInputs = [
    dive
    jq
    skopeo
  ] ++ lib.optional (pkgs ? mdsh) pkgs.mdsh;

  shellHook = ''
    # try to work aroud build issues
    unset TMPDIR
  '';
}
