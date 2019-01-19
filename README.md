# docker-nixpkgs: docker images from nixpkgs

This project is a collection of docker images automatically produced with Nix
and the latest nixpkgs package set. It even refreshes every morning a 4:00 UTC
thanks to the [Gitlab CI schedules][gitlab-schedules].

It's also a good demonstration on how to build and publish Docker images with
Nix.

Always keep your docker images fresh!

## Why use Nix to build docker images?

Nix has a number of advantages over Dockerfile when producing docker images:

* builds are actually reproducible
* Nix will only rebuild the minimum set of changes
* Nix can produce automatic optimised layers for you

## Example usage

Here is an example of using one of the docker images. Usage will change from
image to image.

```
# the user must have an account at gitlab
$ docker login registry.gitlab.com
# run the curl image which has curl as an entry-point
$ docker run -ti --rm registry.gitlab.com/zimbatm/docker-nixpkgs/curl http://ifconfig.co
180.52.248.114
```

## List of images

| Image           | Description           |
| ---             | ---                   |
| curl            | CLI only              |
| kubectl         | CLI only              |
| kubernetes-helm | CLI only              |
| nix             | nix with deps         |
| nix-unstable    | nixUnstable with deps |

## Channels

| Name           |
| ---            |
| nixos-unstable |
| nixos-18.09    |


[gitlab-schedules]: https://gitlab.com/zimbatm/docker-nixpkgs/pipeline_schedules

