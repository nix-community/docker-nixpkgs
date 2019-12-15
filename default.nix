import <nixpkgs> {
  # docker images run on Linux
  system = "x86_64-linux";
  config = {};
  overlays = [
    (import ./overlay.nix)
  ];
}
