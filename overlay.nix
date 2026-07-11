_: pkgs:
let
  importDir = import ./lib/importDir.nix {
    inherit (pkgs) lib;
  };
in
{
  # builder stuff can be in the top-level
  buildCLIImage = pkgs.callPackage ./lib/buildCLIImage.nix { };

  flakeParameters = {
    nixpkgsChannel = if builtins.getEnv("NIXPKGS_CHANNEL") != "" then builtins.getEnv("NIXPKGS_CHANNEL") else "nixos-23.05";
  };

  # docker images must be lower-cased
  docker-nixpkgs = importDir (path: pkgs.callPackage path { }) ./images;

  # used to build nix-env compatible user environments
  mkUserEnvironment = pkgs.callPackage ./lib/mkUserEnvironment.nix { };

  # gitMinimal still ships with perl and python
  gitReallyMinimal = (
    pkgs.git.override {
      perlSupport = false;
      pythonSupport = false;
      withManual = false;
      withpcre2 = false;
    }
  ).overrideAttrs (
    _: {
      # installCheck is broken when perl is disabled
      doInstallCheck = false;
    }
  );

}
