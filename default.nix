{
  system ? builtins.currentSystem
}: let
  pkgs = import ./pkgs.nix system;
in
pkgs.docker-nixpkgs
