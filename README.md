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
| couchpotato     | CLI only              |
| busybox         | CLI only              |
| curl            | CLI only              |
| docker-compose  | CLI only              |
| kubectl         | CLI only              |
| kubernetes-helm | CLI only              |
| nginx           | CLI only              |
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
| nixos-20.03    | nixos-20.03 | only minor versions that include security updates |

## Docker Hub

All images are automatically built and pushed to Docker Hub.

### Image matrix

`> ./dockerhub-image-matrix`
<!-- BEGIN mdsh -->
| Image / Tag | latest | nixos-20.03 |
| ---         | ---    | ---         |
| [nixpkgs/bash](https://hub.docker.com/r/nixpkgs/bash) | [![](https://images.microbadger.com/badges/image/nixpkgs/bash.svg)](https://microbadger.com/images/nixpkgs/bash) | [![](https://images.microbadger.com/badges/image/nixpkgs/bash:nixos-20.03.svg)](https://microbadger.com/images/nixpkgs/bash:nixos-20.03) |
| [nixpkgs/busybox](https://hub.docker.com/r/nixpkgs/busybox) | [![](https://images.microbadger.com/badges/image/nixpkgs/busybox.svg)](https://microbadger.com/images/nixpkgs/busybox) | [![](https://images.microbadger.com/badges/image/nixpkgs/busybox:nixos-20.03.svg)](https://microbadger.com/images/nixpkgs/busybox:nixos-20.03) |
| [nixpkgs/cachix](https://hub.docker.com/r/nixpkgs/cachix) | [![](https://images.microbadger.com/badges/image/nixpkgs/cachix.svg)](https://microbadger.com/images/nixpkgs/cachix) | [![](https://images.microbadger.com/badges/image/nixpkgs/cachix:nixos-20.03.svg)](https://microbadger.com/images/nixpkgs/cachix:nixos-20.03) |
| [nixpkgs/cachix-flakes](https://hub.docker.com/r/nixpkgs/cachix-flakes) | [![](https://images.microbadger.com/badges/image/nixpkgs/cachix-flakes.svg)](https://microbadger.com/images/nixpkgs/cachix-flakes) | [![](https://images.microbadger.com/badges/image/nixpkgs/cachix-flakes:nixos-20.03.svg)](https://microbadger.com/images/nixpkgs/cachix-flakes:nixos-20.03) |
| [nixpkgs/caddy](https://hub.docker.com/r/nixpkgs/caddy) | [![](https://images.microbadger.com/badges/image/nixpkgs/caddy.svg)](https://microbadger.com/images/nixpkgs/caddy) | [![](https://images.microbadger.com/badges/image/nixpkgs/caddy:nixos-20.03.svg)](https://microbadger.com/images/nixpkgs/caddy:nixos-20.03) |
| [nixpkgs/couchpotato](https://hub.docker.com/r/nixpkgs/couchpotato) | [![](https://images.microbadger.com/badges/image/nixpkgs/couchpotato.svg)](https://microbadger.com/images/nixpkgs/couchpotato) | [![](https://images.microbadger.com/badges/image/nixpkgs/couchpotato:nixos-20.03.svg)](https://microbadger.com/images/nixpkgs/couchpotato:nixos-20.03) |
| [nixpkgs/curl](https://hub.docker.com/r/nixpkgs/curl) | [![](https://images.microbadger.com/badges/image/nixpkgs/curl.svg)](https://microbadger.com/images/nixpkgs/curl) | [![](https://images.microbadger.com/badges/image/nixpkgs/curl:nixos-20.03.svg)](https://microbadger.com/images/nixpkgs/curl:nixos-20.03) |
| [nixpkgs/devcontainer](https://hub.docker.com/r/nixpkgs/devcontainer) | [![](https://images.microbadger.com/badges/image/nixpkgs/devcontainer.svg)](https://microbadger.com/images/nixpkgs/devcontainer) | [![](https://images.microbadger.com/badges/image/nixpkgs/devcontainer:nixos-20.03.svg)](https://microbadger.com/images/nixpkgs/devcontainer:nixos-20.03) |
| [nixpkgs/docker-compose](https://hub.docker.com/r/nixpkgs/docker-compose) | [![](https://images.microbadger.com/badges/image/nixpkgs/docker-compose.svg)](https://microbadger.com/images/nixpkgs/docker-compose) | [![](https://images.microbadger.com/badges/image/nixpkgs/docker-compose:nixos-20.03.svg)](https://microbadger.com/images/nixpkgs/docker-compose:nixos-20.03) |
| [nixpkgs/hugo](https://hub.docker.com/r/nixpkgs/hugo) | [![](https://images.microbadger.com/badges/image/nixpkgs/hugo.svg)](https://microbadger.com/images/nixpkgs/hugo) | [![](https://images.microbadger.com/badges/image/nixpkgs/hugo:nixos-20.03.svg)](https://microbadger.com/images/nixpkgs/hugo:nixos-20.03) |
| [nixpkgs/kubectl](https://hub.docker.com/r/nixpkgs/kubectl) | [![](https://images.microbadger.com/badges/image/nixpkgs/kubectl.svg)](https://microbadger.com/images/nixpkgs/kubectl) | [![](https://images.microbadger.com/badges/image/nixpkgs/kubectl:nixos-20.03.svg)](https://microbadger.com/images/nixpkgs/kubectl:nixos-20.03) |
| [nixpkgs/kubernetes-helm](https://hub.docker.com/r/nixpkgs/kubernetes-helm) | [![](https://images.microbadger.com/badges/image/nixpkgs/kubernetes-helm.svg)](https://microbadger.com/images/nixpkgs/kubernetes-helm) | [![](https://images.microbadger.com/badges/image/nixpkgs/kubernetes-helm:nixos-20.03.svg)](https://microbadger.com/images/nixpkgs/kubernetes-helm:nixos-20.03) |
| [nixpkgs/nginx](https://hub.docker.com/r/nixpkgs/nginx) | [![](https://images.microbadger.com/badges/image/nixpkgs/nginx.svg)](https://microbadger.com/images/nixpkgs/nginx) | [![](https://images.microbadger.com/badges/image/nixpkgs/nginx:nixos-20.03.svg)](https://microbadger.com/images/nixpkgs/nginx:nixos-20.03) |
| [nixpkgs/nix](https://hub.docker.com/r/nixpkgs/nix) | [![](https://images.microbadger.com/badges/image/nixpkgs/nix.svg)](https://microbadger.com/images/nixpkgs/nix) | [![](https://images.microbadger.com/badges/image/nixpkgs/nix:nixos-20.03.svg)](https://microbadger.com/images/nixpkgs/nix:nixos-20.03) |
| [nixpkgs/nix-flakes](https://hub.docker.com/r/nixpkgs/nix-flakes) | [![](https://images.microbadger.com/badges/image/nixpkgs/nix-flakes.svg)](https://microbadger.com/images/nixpkgs/nix-flakes) | [![](https://images.microbadger.com/badges/image/nixpkgs/nix-flakes:nixos-20.03.svg)](https://microbadger.com/images/nixpkgs/nix-flakes:nixos-20.03) |
| [nixpkgs/nix-unstable](https://hub.docker.com/r/nixpkgs/nix-unstable) | [![](https://images.microbadger.com/badges/image/nixpkgs/nix-unstable.svg)](https://microbadger.com/images/nixpkgs/nix-unstable) | [![](https://images.microbadger.com/badges/image/nixpkgs/nix-unstable:nixos-20.03.svg)](https://microbadger.com/images/nixpkgs/nix-unstable:nixos-20.03) |
<!-- END mdsh -->
## Adding new images

To add a new image to the project, create a new folder under
`./images/<image-name>` with a default.nix that returns the docker image.

Then run `nix-build -A <image-name>` to test that it builds, and
then use
`docker load -i /nix/store/...<image-name>.tar.gz` to load and test the image.

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

## Related projects

* The [docker-library](https://github.com/docker-library/official-images#readme)
  is an image set maintained by the Docker Inc. team and contain
  officially-supported images.

* [Nixery](https://nixery.dev/) is a pretty cool service that builds docker
  images from nixpkgs attributes on the fly.

## License

Copyright (c) 2019 zimbatm and contributors.

Licensed under the MIT.
