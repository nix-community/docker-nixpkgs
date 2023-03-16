# docker-nixpkgs: docker images from nixpkgs

> Docker recently requested that we start paying $420.-/year in order to keep
> the organization. So we moved the images to GitHub. Sorry for the
> inconvenience.

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

## Channels

Each image is built with the following nixpkgs channels and map to the
following image tag.

The version of the packages included in each image depends on what version the
nixpkgs channel describes.

| Channel        | Image Tag   | Description                                       |
| ---            | ---         | ---                                               |
| nixos-22.05    | nixos-22.05 | only minor versions that include security updates |
| nixos-22.11    | nixos-22.11 | only minor versions that include security updates |
| nixos-unstable | latest      | latest and greatest, major versions might change  |

## List of images

Here is the current list of images that are provided. Missing one? Send an
[image request](#image-request).

All images are automatically built and published to Docker Hub, and served
on our custom domain, courtesy of [Scarf](https://scarf.sh).

`> ./readme-image-matrix`
<!-- BEGIN mdsh -->
| Image / Tag | Pull |
| ---         | ---  |
| [nixpkgs/bash](https://hub.docker.com/r/nixpkgs/bash)| `docker pull docker.nix-community.org/nixpkgs/bash` |
| [nixpkgs/busybox](https://hub.docker.com/r/nixpkgs/busybox)| `docker pull docker.nix-community.org/nixpkgs/busybox` |
| [nixpkgs/cachix](https://hub.docker.com/r/nixpkgs/cachix)| `docker pull docker.nix-community.org/nixpkgs/cachix` |
| [nixpkgs/cachix-flakes](https://hub.docker.com/r/nixpkgs/cachix-flakes)| `docker pull docker.nix-community.org/nixpkgs/cachix-flakes` |
| [nixpkgs/caddy](https://hub.docker.com/r/nixpkgs/caddy)| `docker pull docker.nix-community.org/nixpkgs/caddy` |
| [nixpkgs/curl](https://hub.docker.com/r/nixpkgs/curl)| `docker pull docker.nix-community.org/nixpkgs/curl` |
| [nixpkgs/devcontainer](https://hub.docker.com/r/nixpkgs/devcontainer)| `docker pull docker.nix-community.org/nixpkgs/devcontainer` |
| [nixpkgs/docker-compose](https://hub.docker.com/r/nixpkgs/docker-compose)| `docker pull docker.nix-community.org/nixpkgs/docker-compose` |
| [nixpkgs/hugo](https://hub.docker.com/r/nixpkgs/hugo)| `docker pull docker.nix-community.org/nixpkgs/hugo` |
| [nixpkgs/kubectl](https://hub.docker.com/r/nixpkgs/kubectl)| `docker pull docker.nix-community.org/nixpkgs/kubectl` |
| [nixpkgs/kubernetes-helm](https://hub.docker.com/r/nixpkgs/kubernetes-helm)| `docker pull docker.nix-community.org/nixpkgs/kubernetes-helm` |
| [nixpkgs/nginx](https://hub.docker.com/r/nixpkgs/nginx)| `docker pull docker.nix-community.org/nixpkgs/nginx` |
| [nixpkgs/nix](https://hub.docker.com/r/nixpkgs/nix)| `docker pull docker.nix-community.org/nixpkgs/nix` |
| [nixpkgs/nix-flakes](https://hub.docker.com/r/nixpkgs/nix-flakes)| `docker pull docker.nix-community.org/nixpkgs/nix-flakes` |
| [nixpkgs/nix-unstable](https://hub.docker.com/r/nixpkgs/nix-unstable)| `docker pull docker.nix-community.org/nixpkgs/nix-unstable` |
| [nixpkgs/nix-unstable-static](https://hub.docker.com/r/nixpkgs/nix-unstable-static)| `docker pull docker.nix-community.org/nixpkgs/nix-unstable-static` |
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
we are always thrilled to receive pull requests, and do our best to process
them as fast as we can.

## Related projects

* The [docker-library](https://github.com/docker-library/official-images#readme)
  is an image set maintained by the Docker Inc. team and contain
  officially-supported images.

* [Nixery](https://nixery.dev/) is a pretty cool service that builds docker
  images from nixpkgs attributes on the fly.

## License

Copyright (c) 2021 @zimbatm and contributors.

Licensed under the MIT.
