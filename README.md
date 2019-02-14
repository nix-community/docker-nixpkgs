# docker-nixpkgs: docker images from nixpkgs

This project is a collection of docker images automatically produced with Nix
and the latest nixpkgs package set. All the images are refreshed daily with
the latest versions of nixpkgs.

It's also a good demonstration on how to build and publish Docker images with
Nix.

Always keep your docker images fresh!

## Why use Nix to build docker images?

Nix has a number of advantages over Dockerfile when producing docker images:

* builds are actually reproducible
* Nix will only rebuild the minimum set of changes
* Nix can produce automatic optimised layers for you
* nixpkgs provides automatic security updates

## Example usage

Here is an example of using one of the docker images. Usage will change from
image to image.

```
# run the curl image which has curl as an entry-point
$ docker run -ti --rm nixpkgs/curl http://ifconfig.co
180.52.248.114
```

## List of images

| Image           | Description           |
| ---             | ---                   |
| bash            | CLI only              |
| busybox         | CLI only              |
| curl            | CLI only              |
| docker-compose  | CLI only              |
| kubectl         | CLI only              |
| kubernetes-helm | CLI only              |
| nix             | nix with deps         |
| nix-unstable    | nixUnstable with deps |

## Channels

| Name           | Description                |
| ---            | ---                        |
| nixos-unstable | the :latest version        |
| nixos-18.09    | automatic security updates |

## License

Copyright (c) 2019 zimbatm and contributors.

Licensed under the MIT.
