{ buildCLIImage
, couchpotato
}:
buildCLIImage {
  drv = couchpotato;

  # TODO: expose 5050

  # TODO: create /couchpotato.sh entry-point

  # TODO: run as non-root user

  # TODO: /data volume
}
