{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    devshell.url = "github:numtide/devshell";
  };

  outputs = { self, nixpkgs, flake-utils, devshell, ... }:
    flake-utils.lib.eachDefaultSystem (system: {
      formatter = nixpkgs.legacyPackages.${system}.nixpkgs-fmt;
      docker-nixpkgs =
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [
              (import ./overlay.nix)
            ];
          };
        in
        pkgs.docker-nixpkgs;
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
