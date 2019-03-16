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

Here is the current list of images that are provided. Missing one? Send an
[image request](#image-request).

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

## Docker Hub

All images are automatically built and pushed to Docker Hub.

### Image matrix

`> ./dockerhub-image-matrix`
<!-- BEGIN mdsh -->
| Image / Tag | latest | nixos-18.09 | nixos-19.03 |
| ---         | ---    | ---         | ---         |
| [nixpkgs/bash](https://hub.docker.com/r/nixpkgs/bash) | ![](https://images.microbadger.com/badges/image/nixpkgs/bash.svg) | ![](https://images.microbadger.com/badges/image/nixpkgs/bash:nixos-18.09.svg) | ![](https://images.microbadger.com/badges/image/nixpkgs/bash:nixos-19.03.svg) |
| [nixpkgs/busybox](https://hub.docker.com/r/nixpkgs/busybox) | ![](https://images.microbadger.com/badges/image/nixpkgs/busybox.svg) | ![](https://images.microbadger.com/badges/image/nixpkgs/busybox:nixos-18.09.svg) | ![](https://images.microbadger.com/badges/image/nixpkgs/busybox:nixos-19.03.svg) |
| [nixpkgs/curl](https://hub.docker.com/r/nixpkgs/curl) | ![](https://images.microbadger.com/badges/image/nixpkgs/curl.svg) | ![](https://images.microbadger.com/badges/image/nixpkgs/curl:nixos-18.09.svg) | ![](https://images.microbadger.com/badges/image/nixpkgs/curl:nixos-19.03.svg) |
| [nixpkgs/docker-compose](https://hub.docker.com/r/nixpkgs/docker-compose) | ![](https://images.microbadger.com/badges/image/nixpkgs/docker-compose.svg) | ![](https://images.microbadger.com/badges/image/nixpkgs/docker-compose:nixos-18.09.svg) | ![](https://images.microbadger.com/badges/image/nixpkgs/docker-compose:nixos-19.03.svg) |
| [nixpkgs/kubectl](https://hub.docker.com/r/nixpkgs/kubectl) | ![](https://images.microbadger.com/badges/image/nixpkgs/kubectl.svg) | ![](https://images.microbadger.com/badges/image/nixpkgs/kubectl:nixos-18.09.svg) | ![](https://images.microbadger.com/badges/image/nixpkgs/kubectl:nixos-19.03.svg) |
| [nixpkgs/kubernetes-helm](https://hub.docker.com/r/nixpkgs/kubernetes-helm) | ![](https://images.microbadger.com/badges/image/nixpkgs/kubernetes-helm.svg) | ![](https://images.microbadger.com/badges/image/nixpkgs/kubernetes-helm:nixos-18.09.svg) | ![](https://images.microbadger.com/badges/image/nixpkgs/kubernetes-helm:nixos-19.03.svg) |
| [nixpkgs/nix](https://hub.docker.com/r/nixpkgs/nix) | ![](https://images.microbadger.com/badges/image/nixpkgs/nix.svg) | ![](https://images.microbadger.com/badges/image/nixpkgs/nix:nixos-18.09.svg) | ![](https://images.microbadger.com/badges/image/nixpkgs/nix:nixos-19.03.svg) |
| [nixpkgs/nix-unstable](https://hub.docker.com/r/nixpkgs/nix-unstable) | ![](https://images.microbadger.com/badges/image/nixpkgs/nix-unstable.svg) | ![](https://images.microbadger.com/badges/image/nixpkgs/nix-unstable:nixos-18.09.svg) | ![](https://images.microbadger.com/badges/image/nixpkgs/nix-unstable:nixos-19.03.svg) |
<!-- END mdsh -->
## Adding new images

To add a new image to the project, create a new folder under
`./images/<image-name>` with a default.nix that returns the docker image.

Then run `nix-build release.nix -A <image-name>` to test that it builds, and
then use
`docker load -i /nix/store/...<image-name>.tar.gz` to load and test the image.

## Related projects

The [docker-library](https://github.com/docker-library/official-images#readme)
is an image set maintained by the Docker Inc. team and contain
officially-supported images.

## User Feedback

### Issues

If you have any problems with or questions about this project, please contact
us through a [GitHub issue](https://github.com/nix-community/docker-nixpkgs/issues/new)

### Image request

[Submit a request](https://github.com/nix-community/docker-nixpkgs/issues/new)
with an accompanying use-case for an image that you would like to see.

### Contributing

You are invited to contribute new features, fixes or updates, large or small;
we are always thrilled to receive pull requests, and do our brest ot process
them as fast as we can.

## License

Copyright (c) 2019 zimbatm and contributors.

Licensed under the MIT.
