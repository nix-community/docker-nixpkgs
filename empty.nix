{ dockerTools
, coreutils
, bashInteractive
, cacert
}:
dockerTools.buildImage {
  name = "nixpkgs";
  tag = "empty";
  contents = [
    coreutils
    bashInteractive
  ];

  config = {
    Cmd = [ "/bin/bash" ];
    Env = [
      "PATH=/root/profile/bin:/bin"
      "SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt"
    ];
  };
}
