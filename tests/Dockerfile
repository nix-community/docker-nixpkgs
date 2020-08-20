FROM nixpkgs-nixos-20.03:cb1996818edf506c0d1665ab147c253c558a7426 AS build

COPY . /src
RUN nix-env -iA "" -f /src \
	&& export-profile ~/.nix-profile /root

FROM scratch
COPY --from=build /root /
CMD [ "/bin/bash" ]


