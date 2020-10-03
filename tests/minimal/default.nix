let
  nixpkgs = fetchTarball {
    name = "nixpkgs-src";
    url = "https://github.com/NixOS/nixpkgs/archive/${builtins.readFile ./nixpkgsCommit}.tar.gz";
    sha256 = builtins.readFile ./nixpkgsSha;
  };
in import nixpkgs {
  overlays = [];
  config = {};
}
