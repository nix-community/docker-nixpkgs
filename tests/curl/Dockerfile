FROM base AS build

COPY . src
RUN nix-env -if src -A curl -A cacert \
  && export-profile /dist

FROM scratch
COPY --from=build /dist /
ENV \
  PATH=/run/profile/bin \
  # To allow curl to find certs
  NIX_SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt
