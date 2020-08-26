FROM nixpkgs:9nrg98xy3h822fan70x1gk1yjp406wvz AS build

COPY . src
RUN while ! timeout 5 nix-env -iA "" -f src; do :; done \
	&& export-profile /dist

FROM scratch
COPY --from=build /dist /
CMD [ "bash" ]
ENV NIX_SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt



