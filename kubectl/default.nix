{ dockerTools
, cacert
, kubectl
}:
dockerTools.buildImage {
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
