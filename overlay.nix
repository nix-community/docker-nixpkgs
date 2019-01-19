_: pkgs: {
  # docker images must be lower-cased
  docker-nixpkgs = rec {

    curl = pkgs.callPackage ./curl {};
    kubectl = pkgs.callPackage ./kubectl {};
    kubernetes-helm = pkgs.callPackage ./kubernetes-helm {};
    nix = pkgs.callPackage ./nix {};
    nix-unstable = nix.overrideAttrs (self: { nix = pkgs.nixUnstable; });

  };
}
