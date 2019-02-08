{ dockerTools
, busybox
, cacert
}:
{ drv # derivation to build the image for
# Name of the binary to run by default
, binName ? (builtins.parseDrvName drv.name).name
}:
dockerTools.buildLayeredImage {
  name = drv.name;

  contents = [
    # add a /bin/sh on all images
    busybox
    # most program need TLS certs
    cacert
    drv
  ];

  config = {
    Cmd = [ "/bin/${binName}" ];
    Env = [
      "PATH=/bin"
      "SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt"
    ];
  };
}
