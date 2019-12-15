{ dockerTools
, bashInteractive
, cacert
, coreutils
, curl
, git
, gnutar
, gzip
, iana-etc
, nix
, xz
}:
let
  # gitMinimal still ships with perl and python
  gitReallyMinimal = (git.override {
      perlSupport = false;
      pythonSupport = false;
      withManual = false;
      withpcre2 = false;
    }).overrideAttrs(_:{
      # installCheck is broken when perl is disabled
      doInstallCheck=false;
    });

  image = dockerTools.buildImageWithNixDb {
    inherit (nix) name;

    contents = [
      ./root
      coreutils
      # add /bin/sh
      bashInteractive
      nix

      # runtime dependencies of nix
      cacert
      gitReallyMinimal
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
  };
in
  image // { meta = nix.meta // image.meta; }
