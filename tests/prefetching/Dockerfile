FROM base AS build

COPY . src
RUN nix-env -v -if src -A hello \
  && export-profile /dist

FROM scratch
COPY --from=build /dist /
