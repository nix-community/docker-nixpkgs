{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-23-05.url = "github:NixOS/nixpkgs/nixos-23.05";
    nixpkgs-22-11.url = "github:NixOS/nixpkgs/nixos-22.11";
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    devshell.url = "github:numtide/devshell";
  };

  outputs = { self, nixpkgs, nixpkgs-23-05, nixpkgs-22-11, flake-utils, devshell, ... }:
    flake-utils.lib.eachDefaultSystem (system: {
      formatter = nixpkgs.legacyPackages.${system}.nixpkgs-fmt;
      docker-nixpkgs =
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [
              (import ./overlay.nix)
              (final: prev: {
                flakeParameters = {
                  nixpkgsChannel = "nixos-unstable";
                };
              })
            ];
          };
          pkgs-23-05 = import nixpkgs-23-05 {
            inherit system;
            overlays = [
              (import ./overlay.nix)
              (final: prev: {
                flakeParameters = {
                  nixpkgsChannel = "nixos-23.05";
                };
              })
            ];
          };
          pkgs-22-11 = import nixpkgs-22-11 {
            inherit system;
            overlays = [
              (import ./overlay.nix)
              (final: prev: {
                flakeParameters = {
                  nixpkgsChannel = "nixos-22.11";
                };
              })
            ];
          };
        in
        {
            "nixos-unstable" = pkgs.docker-nixpkgs;
            "nixos-23.05" = pkgs-23-05.docker-nixpkgs;
            "nixos-22.11" = pkgs-22-11.docker-nixpkgs;
        };
      devShell =
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [
              devshell.overlays.default
              (import ./overlay.nix)
            ];
          };
        in
        pkgs.devshell.mkShell {
          name = "docker-nixpkgs";
          commands = [ ];
          packages = [ ];
          env = [ ];
        };
    });
}
