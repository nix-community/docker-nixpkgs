let
  nixpkgs = fetchTarball {
    name = "nixpkgs-src";
    url = "https://github.com/NixOS/nixpkgs/archive/cb1996818edf506c0d1665ab147c253c558a7426.tar.gz";
    sha256 = "0lb6idvg2aj61nblr41x0ixwbphih2iz8xxc05m69hgsn261hk3j";
  };
  pkgs = import nixpkgs {};
in pkgs.buildEnv {
  name = "env";
  paths = [
    pkgs.hello
    pkgs.bashInteractive
    pkgs.coreutils
    pkgs.curl
    pkgs.cacert
  ];
}
