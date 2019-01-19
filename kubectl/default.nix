{ dockerTools
, cacert
, kubectl
}:
dockerTools.buildLayeredImage {
  inherit (kubectl) name;

  contents = [
    cacert
    kubectl
  ];

  config = {
    Entrypoint = [ "/bin/kubectl" ];
    Env = [
      "PATH=/bin"
      "SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt"
    ];
  };
}
