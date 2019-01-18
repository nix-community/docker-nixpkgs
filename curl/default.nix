{ dockerTools
, cacert
, curl
}:
dockerTools.buildImage {
  inherit (curl) name;

  contents = [
    cacert
    curl
  ];

  config = {
    Entrypoint = [ "/bin/curl" ];
    Env = [
      "PATH=/bin"
      "SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt"
    ];
  };
}
