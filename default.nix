{
  system ? builtins.currentSystem
}: let
  _parts = builtins.split "-" system;
  arch = builtins.elemAt _parts 0;
  os = builtins.elemAt _parts 2;
  system' =
    if os == "darwin"
    then "${arch}-linux"
    else system;
  pkgs =
    import ./pkgs.nix system';
in
pkgs.docker-nixpkgs
