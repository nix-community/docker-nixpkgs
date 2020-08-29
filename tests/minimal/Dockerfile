FROM base AS build

COPY . src
RUN nix-env -if src -A hello \
  && export-profile /dist

FROM scratch
COPY --from=build /dist /
