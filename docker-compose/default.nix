{ buildCLIImage
, docker-compose
}:
buildCLIImage {
  drv = docker-compose;
}
