let
  nixpkgs = builtins.fetchTarball "channel:nixos-23.11";
  pkgs = import nixpkgs { config = { }; overlays = [ ]; };
in
with pkgs;
mkShell {
  buildInputs = [
    dive
    jq
    skopeo
    podman
  ] ++ lib.optional (pkgs ? mdsh) pkgs.mdsh;

  shellHook = ''
    # try to work aroud build issues
    unset TMPDIR

    export NIX_PATH=nixpkgs=${toString nixpkgs}
  '';
}
