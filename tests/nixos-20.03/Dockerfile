FROM niteo/nixpkgs-nixos-20.03:14006b724f3d1f25ecf38238ee723d38b0c2f4ce AS build

COPY . src
RUN nix-env -if src -A curl -A cacert \
  && export-profile /dist

FROM scratch
COPY --from=build /dist /
# To allow curl to find certs
ENV NIX_SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt
