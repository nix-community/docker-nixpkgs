# docker-nixpkgs: docker images from nixpkgs

This project is a collection of docker images automatically produced with Nix
and the latest nixpkgs package set. All the images are refreshed daily with
the latest versions of nixpkgs.

It's also a good demonstration on how to build and publish Docker images with
Nix.

Always keep your docker images fresh!

## Why use Nix to build docker images?

Nix has a number of advantages over Dockerfile when producing docker images:

* builds are more likely to be repeatable and binary reproducible
* Nix will only rebuild the minimum set of changes with no manual intervention
* Nix produces optimised layers with no manual intervention
* nixpkgs provides automatic security updates

## Example usage

Here is an example of using one of the docker images. Usage will change from
image to image.

```
# run the curl image which has curl as an entry-point
$ docker run -ti --rm nixpkgs/curl curl http://ifconfig.co
180.52.248.114
```

## List of images

Here is the current list of images that are provided. Missing one?
[Submit a request](https://github.com/nix-community/docker-nixpkgs/issues/new)

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

Each image is built with the following nixpkgs channels and map to the
following image tag.

The version of the packages included in each image depends on what version the
nixpkgs channel describes.

| Channel        | Image Tag   | Description                                       |
| ---            | ---         | ---                                               |
| nixos-unstable | latest      | latest and greated, major versions might change   |
| nixos-18.09    | nixos-18.09 | only minor versions that include security updates |

## Related projects

The [docker-library](https://github.com/docker-library/official-images#readme)
is an image set maintained by the Docker Inc. team and contain
officially-supported images.

## License

Copyright (c) 2019 zimbatm and contributors.

Licensed under the MIT.
