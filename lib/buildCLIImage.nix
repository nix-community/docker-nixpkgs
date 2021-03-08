{ dockerTools
, busybox
, cacert
}:
{ drv # derivation to build the image for
  # Name of the binary to run by default
, binName ? (builtins.parseDrvName drv.name).name
, extraContents ? [ ]
, meta ? drv.meta
}:
let
  image = dockerTools.buildLayeredImage {
    name = drv.name;

    contents = [
      # add a /bin/sh on all images
      busybox
      # most program need TLS certs
      cacert
      drv
    ] ++ extraContents;

    config = {
      Cmd = [ "/bin/${binName}" ];
      Env = [
        "PATH=/bin"
        "SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt"
      ];
      Labels = {
        # https://github.com/microscaling/microscaling/blob/55a2d7b91ce7513e07f8b1fd91bbed8df59aed5a/Dockerfile#L22-L33
        "org.label-schema.vcs-ref" = "master";
        "org.label-schema.vcs-url" = "https://github.com/nix-community/docker-nixpkgs";
      };
    };
  };
in
image // { meta = meta // image.meta; }
