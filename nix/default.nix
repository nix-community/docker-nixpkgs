{ dockerTools
, bash
, cacert
, coreutils
, curl
, gitMinimal
, gnutar
, gzip
, iana-etc
, nix
, xz
}:
dockerTools.buildImageWithNixDb {
  inherit (nix) name;

  contents = [
    ./root
    coreutils
    # add /bin/sh
    bash
    nix

    # runtime dependencies of nix
    cacert
    gitMinimal
    gnutar
    gzip
    xz

    # for haskell binaries
    iana-etc
  ];

  extraCommands = ''
    # for /usr/bin/env
    mkdir usr
    ln -s ../bin usr/bin

    # make sure /tmp exists
    mkdir -m 0777 tmp
  '';

  config = {
    Cmd = [ "/bin/bash" ];
    Env = [
      "ENV=/etc/profile.d/nix.sh"
      "NIX_PATH=nixpkgs=channel:nixpkgs-unstable"
      "PAGER=cat"
      "PATH=/usr/bin:/bin"
      "SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt"
    ];
  };
}
