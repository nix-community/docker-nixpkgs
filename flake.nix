{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-24-05.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-24-11.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-25-05.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    devshell.url = "github:numtide/devshell";
  };

  outputs = { self, nixpkgs, nixpkgs-24-05, nixpkgs-24-11, nixpkgs-25-05, flake-utils, devshell, ... }:
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
          pkgs-24-05 = import nixpkgs-24-05 {
            inherit system;
            overlays = [
              (import ./overlay.nix)
              (final: prev: {
                flakeParameters = {
                  nixpkgsChannel = "nixos-24.05";
                };
              })
            ];
          };
          pkgs-24-11 = import nixpkgs-24-11 {
            inherit system;
            overlays = [
              (import ./overlay.nix)
              (final: prev: {
                flakeParameters = {
                  nixpkgsChannel = "nixos-24.11";
                };
              })
            ];
          };
          pkgs-25-05 = import nixpkgs-25-05 {
            inherit system;
            overlays = [
              (import ./overlay.nix)
              (final: prev: {
                flakeParameters = {
                  nixpkgsChannel = "nixos-25.05";
                };
              })
            ];
          };
        in
        {
            "nixos-unstable" = pkgs.docker-nixpkgs;
            "nixos-24.05" = pkgs-24-05.docker-nixpkgs;
            "nixos-24.11" = pkgs-24-11.docker-nixpkgs;
            "nixos-25.05" = pkgs-25-05.docker-nixpkgs;
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
