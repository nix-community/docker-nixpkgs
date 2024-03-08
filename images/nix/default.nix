{ dockerTools
, bashInteractive
, cacert
, coreutils
, curl
, gitReallyMinimal
, gnutar
, gzip
, iana-etc
, nix
, openssh
, xz
, extraContents ? [ ]
, extraEnv ? [ ]
}:
let
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
      openssh
      xz

      # for haskell binaries
      iana-etc
    ] ++ extraContents;

    extraCommands = ''
      # for /usr/bin/env
      mkdir usr
      ln -s ../bin usr/bin

      # make sure /tmp exists
      mkdir -m 1777 tmp

      # need a HOME
      mkdir -vp root
    '';

    config = {
      Cmd = [ "/bin/bash" ];
      Env = [
        "ENV=/etc/profile.d/nix.sh"
        "BASH_ENV=/etc/profile.d/nix.sh"
        "NIX_BUILD_SHELL=/bin/bash"
        "NIX_PATH=nixpkgs=${./fake_nixpkgs}"
        "PAGER=cat"
        "PATH=/usr/bin:/bin"
        "SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt"
        "USER=root"
      ] ++ extraEnv;
    };
  };
in
image // { meta = nix.meta // image.meta; }
