{ path, lib, nix }:
let
  channel =
    builtins.replaceStrings
      ["\n"]
      [""]
      "nixos-${builtins.readFile "${path}/.version"}";
in
  lib.makeImage {
    image = {
      name = "nix";
      tag = "latest";

      run = ''
        chmod u+w root
        echo 'https://nixos.org/channels/${channel} nixpkgs' > root/.nix-channels
      '';

      interactive = true;
    };
    environment.systemPackages = [ nix ];
    nix = {
      enable = true;
      useSandbox = false;
      package = nix;
    };
  }
