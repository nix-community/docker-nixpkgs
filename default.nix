{}:
let
  inherit (import ./nix) pkgs sources;
  inherit (pkgs) lib;

  # A mapping from nixpkgs channel names to a docker image for that channel
  images = lib.mapAttrs (attr: nixpkgs:
    # Allows specifying --argstr nixHash on the CLI
    { nixHash ? null }: import ./image.nix {
      inherit nixHash;
      # Rename the derivation to accomodate the standard niv naming of nixpkgs
      nixpkgs = fetchTarball {
        name = "nixpkgs-src";
        inherit (nixpkgs) url sha256;
      };
    }
  ) sources;

  # Updates the images on DockerHub if necessary
  imageUpdater = pkgs.writeShellScript "update" (lib.concatStringsSep "\n"
    (lib.mapAttrsToList (attr: nixpkgs: ''
      ${pkgs.scripts.image-update} \
        ${./.} ${attr} ${nixpkgs.rev}
    '') sources));

  # Runs all tests for all nixpkgs channels
  testRunner = pkgs.writeShellScript "test-runner" (lib.concatStringsSep "\n"
    (lib.mapAttrsToList (attr: nixpkgs: ''
      ${pkgs.scripts.run-tests} \
        ${./.} ${attr}
    '') sources));

  # Runs niv update
  nixpkgsUpdater = pkgs.writeShellScript "update" ''
    echo "Updating niv nixpkgs sources.." >&2
    ${lib.getBin pkgs.niv}/bin/niv update
  '';

in {
  # For debugging/introspection
  inherit pkgs sources;

  # For building the images
  inherit images;

  # Updaters for CI
  inherit testRunner imageUpdater nixpkgsUpdater;

  # Needed for adding a new channel, used in shell.nix
  devShell = pkgs.mkShell {
    buildInputs = [ pkgs.niv ];
  };
}
