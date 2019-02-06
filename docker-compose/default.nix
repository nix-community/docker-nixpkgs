{ dockerTools
, cacert
, docker-compose
}:
dockerTools.buildLayeredImage {
  inherit (docker-compose) name;

  contents = [
    cacert
    docker-compose
  ];

  config = {
    Entrypoint = [ "/bin/docker-compose" ];
    Env = [
      "PATH=/bin"
      "SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt"
    ];
  };
}
