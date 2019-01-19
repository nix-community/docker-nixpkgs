{ dockerTools
, cacert
, kubernetes-helm
}:
dockerTools.buildImage {
  inherit (kubernetes-helm) name;

  contents = [
    cacert
    kubernetes-helm
  ];

  config = {
    Entrypoint = [ "/bin/helm" ];
    Env = [
      "PATH=/bin"
      "SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt"
    ];
  };
}
