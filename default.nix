{ nixpkgs ? <nixpkgs> }:
let
  sources = import ./nix/sources.nix;
  nix-container-images = sources."nix-container-images";
in
import nixpkgs {
  # docker images run on Linux
  system = "x86_64-linux";
  config = {};
  overlays = [
    (import "${nix-container-images}/overlay.nix")
    (import ./overlay.nix)
  ];
}
