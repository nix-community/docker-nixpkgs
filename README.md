# nix-docker-base: Nix Docker base images for fast and minimal builds

This project automatically generates Docker images for nixpkgs channels. The images come with a prefetched nixpkgs, corresponding to the image tag, which is the nixpkgs commit hash. All basic Nix utilities are preinstalled, including cachix. Also included is the `export-profile` script, allowing super minimal images via [multi-stage builds](https://docs.docker.com/develop/develop-images/multistage-build/).


See the [Usage](#usage) section for how to use it in your project.

## Features

### Prefetched nixpkgs tarballs

All images come prefetched with the [nixpkgs](https://github.com/NixOS/nixpkgs) version corresponding to the image tag. So the image `niteo/nixpkgs-nixos-20.03:14006b724f3d1f25ecf38238ee723d38b0c2f4ce` contains a prefetched tarball of [14006b724f3d](https://github.com/NixOS/nixpkgs/tree/14006b724f3d1f25ecf38238ee723d38b0c2f4ce). This allows Nix builds that pin nixpkgs to that version to start quickly, without having to first fetch and unpack a tarball.

### Preinstalled dependencies

All images come preinstalled with a basic set of dependencies needed for working with Nix. This currently includes [cachix](https://cachix.org/) and all dependencies of Nix, but may be expanded in the future as the need arises. Since the intend is to only use these images as a first stage in multi-stage builds, they won't influence the final image size, allowing the addition of more tools without a significant cost.

These dependencies notably come from the very nixpkgs version that is prefetched. If you need these tools or their dependencies in a Nix build, this saves you the cost of having to download them.

### Automatic channel updates

Every hour, the [Nixpkgs update](https://github.com/niteoweb/docker-nixpkgs/actions?query=workflow%3A%22Nixpkgs+update%22) GitHub Actions workflow runs to detect any channel updates. If that's the case, an update commit is pushed to master, which triggers the [Image update](https://github.com/niteoweb/docker-nixpkgs/actions?query=workflow%3A%22Test+%26+image+update%22) workflow to build the new images and push them to DockerHub.

Additionally, if this repository changes how images are built, the image tags corresponding to the latest channel versions are updated to incorporate these changes. This is the only way in which tagged images are updated, meaning once a nixpkgs channel commit is outdated, its image won't get updated anymore. So if this repository receives an update, you need to update nixpkgs to the latest version of the channel.

### Minimal multi-stage builds

The images contain the `export-profile` utility, which allows easy creation of a final stage in Docker [multi-stage builds](https://docs.docker.com/develop/develop-images/multistage-build/). The resulting image then contains only exactly the dependencies needed to run the programs you specify, nothing else.

## Usage

### Pinning nixpkgs

To use this for your project, you should ensure that the prefetched nixpkgs tarball can be used, such that builds can start as fast as possible. This requires that you [pin nixpkgs](https://nixos.wiki/wiki/FAQ/Pinning_Nixpkgs) to the nixpkgs commit of the channel that you wish to use. Specifically, the Nix expression that evaluates to the prefetched version is
```nix
fetchTarball {
  name = "nixpkgs-src";
	url = "https://github.com/NixOS/nixpkgs/archive/<commit>.tar.gz";
	sha256 = "<sha256>";
}
```

Note that choosing the name as `nixpkgs-src` is very important, because Nix can only reuse a prefetched version if the name matches.

Only Nix channels specified in [nix/sources.json](./nix/sources.json) are available, but new ones may be added over time. Also only commits after the addition of the channel are available, so there's no history of commits that goes past when the channel was added to this repository.

#### Using [Niv](https://github.com/nmattia/niv)

Since niv uses `<package name>-src` as the derivation name, you need to ensure that `nixpkgs` is the package name of the nixpkgs source, which is the default for the `NixOS/nixpkgs` repository.

In addition, make sure to specify the correct channel branch. For some time now the main `NixOS/nixpkgs` repository contains all channel branches, so using `NixOS/nixpkgs-channels` isn't necessary.

For a new project wanting to use the `nixos-20.03` branch, the following niv command will set it up correctly:
```bash
niv add NixOS/nixpkgs -b nixos-20.03
```

Note that you may need to run `niv drop nixpkgs` first to remove any previous nixpkgs version.

### Nix expression

To use this project, you need a Nix expression in your project that ideally exposes a single derivation as an attribute for installation. A convenient helper for this is `pkgs.buildEnv`, which allows you to build a derivation that combines multiple other derivations into one. Here is an example `default.nix`, showing how `pkgs.buildEnv` can be used to create an environment with both `pkgs.curl` and `pkgs.cacert` in it:
```nix
let

  # Without niv
  pkgs = fetchTarball {
		name = "nixpkgs-src";
		url = "https://github.com/NixOS/nixpkgs/archive/<commit>.tar.gz";
		sha256 = "<sha256>";
	};

	# With niv
	pkgs = (import nix/sources.nix).nixpkgs;

in {
  myEnv = pkgs.buildEnv {
		name = "env";
		paths = with pkgs; [
			curl
			cacert
		];
	};
}
```

### Dockerfile

The base images are made available under [Niteo on DockerHub](https://hub.docker.com/u/niteo) as `niteo/nixpkgs-<channel>:<commit>`. With the Dockerfile being in the same directory as the projects `default.nix` file, you can install any exposed attribute of that file with the following basic Dockerfile structure
```Dockerfile
FROM niteo/nixpkgs-<channel>:<commit> AS build
# Import the project source
COPY . src
RUN \
  # Install the program to propagate to the final image
  nix-env -f src -iA myEnv \
	# Exports a root directory structure containing all dependencies installed with nix-env
  && export-profile /dist

# Second Docker stage, we start with a completely empty image
FROM scratch
# Copy the /dist root folder from the previous stage into this one
COPY --from=build /dist /
```

#### SSL root certificates

If you require binaries like `curl` in the final image, you need to make sure that it can find the SSL root certificates. To do this:
- Install `pkgs.cacert` in the `build` stage, either by adding it to the environment of the attribute you install, or with an additional nix-env command like
  ```
	  nix-env -f '<nixpkgs>' -iA cacert
	```
- Set the `NIX_SSL_CERT_FILE` environment variable as follows in the final stage
  ```Dockerfile
	ENV NIX_SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt
	```

#### Updating the Dockerfile

Since the nixpkgs commit is embedded into the Dockerfile, it should be kept it sync with the nixpkgs of your Nix files to ensure it being as efficient as possible. So if you update your nixpkgs source to a newer channel commit, be sure to update it in the Dockerfile as well.

If you manage your nixpkgs source with `niv`, this can be achieved automatically with the following commands:
```bash
niv update nixpkgs
channel=$(jq -r .nixpkgs.branch nix/sources.json)
rev=$(jq -r .nixpkgs.rev nix/sources.json)
sed -i "1cFROM niteo/nixpkgs-$channel:$rev AS build"
```

## Development and Contributing

This section is only intended for developers/contributors of this project. Feel free to contribute by opening a PR or open issues for enquiries.

### Adding new nixpkgs channels

After entering a `nix-shell`, adding new nixpkgs channels to track can be done with
```bash
channel=nixos-20.09
niv add NixOS/nixpkgs -n "$channel" -b "$channel"
```

### Running tests

Tests are automatically run by CI, but can also be run manually with
```
nix-build -A testRunner
./result
```

### Adding new tools to the base image

New tools for the base image can be added under `Extra tools` in [image.nix](./image.nix).

### Out-of-tree requirements for forks

- A [DockerHub](https://hub.docker.com/) account. Insert your username for `REGISTRY_USER` in the [push.yml](.github/workflows/push.yml) workflow, and set up the password as a `REGISTRY_PASSWORD` secret for the repository. This is of course needed to update images on DockerHub. Other container registries could work too, but the code needs to be adjusted for that.
- A GitHub personal access token, which you can generate [here](https://github.com/settings/tokens/new). Set this as an `UPDATE_GITHUB_TOKEN` secret in the repository. It's used by the [nixpkgs-update.yml](.github/workflows/nixpkgs-update.yml) workflow to automatically update the niv sources and trigger image updates.

## Related projects

- This project was originally forked from https://github.com/nix-community/docker-nixpkgs, but almost no code remains unchanged
- The official Nix docker images at https://github.com/nixos/docker
- [Nixery](https://nixery.dev/) is a pretty cool service that builds docker images from nixpkgs attributes on the fly
