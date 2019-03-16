_: pkgs: {
  # lib stuff can be in the top-level
  buildCLIImage = pkgs.callPackage ./lib/buildCLIImage.nix {};

  # docker images must be lower-cased
  docker-nixpkgs = {

    bash = pkgs.callPackage ./images/bash {};
    busybox = pkgs.callPackage ./images/busybox {};
    curl = pkgs.callPackage ./images/curl {};
    docker-compose = pkgs.callPackage ./images/docker-compose {};
    kubectl = pkgs.callPackage ./images/kubectl {};
    kubernetes-helm = pkgs.callPackage ./images/kubernetes-helm {};
    nix = pkgs.callPackage ./images/nix {};
    nix-unstable = pkgs.callPackage ./images/nix-unstable {};

  };
}
