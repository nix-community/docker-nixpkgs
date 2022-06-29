{ dockerTools
, lib
, fetchurl
, findutils
, pkgsStatic
, python3
, removeReferencesTo
, runCommand
}:
let
  inherit (pkgsStatic)
    bashInteractive
    busybox
    cacert
    openssl
    ;

  bash = bashInteractive;

  # Get nix from Hydra because the nixpkgs one is not fully static
  nixStaticBin = fetchurl {
    url = "https://hydra.nixos.org/build/181573550/download/1/nix";
    hash = "sha256-zO2xJhQIrLtL/ReTlcorjwsaTO1W5Rnr+sXwcLcujok=";
  };

  nixSymlinks = [
    "nix-build"
    "nix-channel"
    "nix-collect-garbage"
    "nix-copy-closure"
    "nix-daemon"
    "nix-env"
    "nix-hash"
    "nix-instantiate"
    "nix-prefetch-url"
    "nix-shell"
    "nix-store"
  ];

  dirs = [
    "bin"
    "etc/ssl/certs"
    "root"
    "tmp"
    "usr"
  ];

  extraCommands = ''
    rm_ref() {
      ${removeReferencesTo}/bin/remove-references-to "$@"
    }

    # Create a FHS-like file structure
    cp -r ${../nix/root}/* .
    chmod +w etc
    mkdir -p ${toString dirs}

    # For /usr/bin/env
    ln -s ../bin usr/bin

    # Make sure /tmp has the right permissions
    chmod 1777 tmp

    # Add user home folder
    mkdir home

    # Add SSL CA certs
    cp -a "${cacert}/etc/ssl/certs/ca-bundle.crt" etc/ssl/certs/ca-bundle.crt

    # Install base binaries
    cp -a ${busybox}/bin/* bin/
    rm_ref -t ${busybox} bin/busybox

    # Install shell
    cp -a ${bash}/bin/bash bin/
    rm_ref -t ${bash} bin/bash

    # Install nix
    cp -a ${nixStaticBin} bin/nix
    chmod +x bin/nix
    for sym in ${toString nixSymlinks}; do
      ln -sv /bin/nix bin/$sym
    done
    mkdir -p libexec/nix
    ln -s /bin/nix libexec/nix/build-remote

    # Add run-as-user script
    cp -a ${./run_as_user.sh} run_as_user.sh
  '';

  # To debug
  unpacked = runCommand
    "unpacked"
    { buildInputs = [ python3 ]; }
    ''
      mkdir layer
      pushd layer
      ${extraCommands}
      popd
      mv layer $out
    '';

  image = dockerTools.buildImage {
    name = "nix-static";

    inherit extraCommands;

    config = {
      Cmd = [ "/bin/bash" ];
      Env = [
        "NIX_BUILD_SHELL=/bin/bash"
        "PAGER=cat"
        "PATH=/bin"
        "SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt"
      ];
    };
  };
in
image // {
  passthru = image.passthru // { inherit unpacked; };
  meta = image.meta // {
    description = "Nix but statically built";
  };
}
