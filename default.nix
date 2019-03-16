{ nixpkgs ? <nixpkgs> }:
let
  nix-container-images = builtins.fetchTarball {
    url = "https://github.com/nlewo/nix-container-images/archive/7577da87f7249442b51359e36a0f0493949a14d6.tar.gz";
    sha256 = "0cv3b8gngvb2my1rqs2kxszmwb3s3i72j1wp6jin5f1wjp9km32w";
  };
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
