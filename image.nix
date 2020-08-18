{ nixpkgs
, dockerTools
, coreutils
, bashInteractive
, nix
, cacert
, gitReallyMinimal
, gnutar
, gzip
, openssh
, xz
, stdenv
, cachix
, shadow
}:
dockerTools.buildImageWithNixDb {
  name = "nixpkgs-${nixpkgs.branch}";
  tag = nixpkgs.rev;
  contents = [
    "${./images/nix/root}"
    coreutils
    bashInteractive
    nix

    # runtime dependencies of nix
    cacert
    gitReallyMinimal
    gnutar
    gzip
    openssh
    xz

    cachix

    shadow

    # For fetchTarballs
    #(fetchTarball {
    #  inherit (nixpkgs) url sha256;
    #})
    # For niv fetches
    # TODO: This also puts all of nixpkgs' files in / .. :/
    nixpkgs

    #(runCommandNoCC "stuff" {} ''
    #  mkdir -p root/
    #'')
  ];

  extraCommands = ''
    # for /usr/bin/env
    mkdir usr
    ln -s ../bin usr/bin

    # make sure /tmp exists
    mkdir -m 1777 tmp

    # need a HOME
    #mkdir -vp root
  '';

  config = {
    Cmd = [ "/bin/bash" ];
    Env = [
      "ENV=/etc/profile.d/nix.sh"
      "BASH_ENV=/etc/profile.d/nix.sh"
      "NIX_BUILD_SHELL=/bin/bash"
      "NIX_PATH=nixpkgs=${nixpkgs}"
      "PAGER=cat"
      "PATH=/nix/var/nix/profiles/default/bin:/bin/usr/bin:/bin"
      "SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt"
      "USER=root"
    ];
  };
}
