{ buildCLIImage
, docker-compose ? null
, python3Packages
}:
buildCLIImage {
  drv =
    if docker-compose == null
    then python3Packages.docker_compose
    else docker-compose # nixos 19.03+
    ;
}
