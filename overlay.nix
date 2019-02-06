_: pkgs: {
  # docker images must be lower-cased
  docker-nixpkgs = rec {

    curl = pkgs.callPackage ./curl {};
    docker-compose = pkgs.callPackage ./docker-compose {
      docker-compose =
         # master
         pkgs.docker-compose or
         # 18.09
         pkgs.python3Packages.docker_compose;
    };
    kubectl = pkgs.callPackage ./kubectl {};
    kubernetes-helm = pkgs.callPackage ./kubernetes-helm {};
    nix = pkgs.callPackage ./nix {};
    nix-unstable = nix.overrideAttrs (self: { nix = pkgs.nixUnstable; });

  };
}
