FROM nixpkgs-nixos-20.03:cb1996818edf506c0d1665ab147c253c558a7426 AS build

COPY . ./src
RUN set -x \
  && drv=$(nix-instantiate /src) \
	&& out=$(nix-store -r "$drv") \
  && nix-store --export $(nix-store -qR "$out") | \
	  NIX_REMOTE=local?root=/root/altroot nix-store --import \
	&& ln -s "$out" /root/profile

FROM nixpkgs:empty
##
COPY --from=build /root/altroot/nix/store /nix/store
COPY --from=build /root/profile /root/profile

#RUN nix-store --load-db < /dbdump


