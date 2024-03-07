system:
# docker images run on Linux
assert builtins.elem system ["x86_64-linux" "aarch64-linux"];
import <nixpkgs> {
  config = { };
  inherit system;
  overlays = [
    (import ./overlay.nix)
  ];
}
