_:
throw ''
This container doesn't include nixpkgs.

Pin your dependencies. Or if you must, override the NIX_PATH environment
variable with eg: "NIX_PATH=nixpkgs=channel:nixos-unstable"
''
