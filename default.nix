{ nixpkgs ? <nixpkgs> }:
import nixpkgs {
  config = {};
  overlays = [
    (import ./overlay.nix)
  ];
}
