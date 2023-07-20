{ dockerTools
, lib
, fetchurl
, findutils
, pkgsStatic
, python3
, removeReferencesTo
, runCommand
, buildPackages
}:
let
  inherit (pkgsStatic)
    bashInteractive
    busybox
    cacert;

  bash = bashInteractive;

  # Get nix from Hydra because the nixpkgs one is not fully static
  nixStaticBin = fetchurl {
    url = "https://hydra.nixos.org/build/228458395/download/1/nix";
    hash = "sha256-H361lUdMpBpBVwInBmpAXKAwjPIf740Jg9Nht0NV66s=";
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

    # Create an unpriveleged user that we can use also without the run-as-user.sh script
    chmod +w $PWD/etc/group $PWD/etc/passwd
    ${buildPackages.shadow}/bin/groupadd --prefix $PWD -g 9000 nixuser
    ${buildPackages.shadow}/bin/useradd --prefix $PWD -m -d /tmp -u 9000 -g 9000 -G nixuser nixuser

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

    # Enable flakes
    mkdir -p etc/nix
    cat <<NIX_CONFIG > etc/nix/nix.conf
    accept-flake-config = true
    experimental-features = nix-command flakes
    NIX_CONFIG

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
        # /host/bin can be used to extend the image with additional binaries
        "PATH=/bin:/host/bin"
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
