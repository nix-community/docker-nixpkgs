_: pkgs: {
  docker-nixpkgs = rec {

    curl = pkgs.callPackage ./curl {};

    nix = pkgs.callPackage ./nix {};

    # docker images must be lower-cased
    nix-unstable = nix.overrideAttrs (self: { 
      nix = pkgs.nixUnstable;
    });

  };
}
