let
  nixpkgs = fetchTarball {
    name = "nixpkgs-src";
    url = "https://github.com/NixOS/nixpkgs/archive/14006b724f3d1f25ecf38238ee723d38b0c2f4ce.tar.gz";
    sha256 = "07hfbilyh818pigfn342v2r05n8061wpjaf1m4h291lf6ydjagis";
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
