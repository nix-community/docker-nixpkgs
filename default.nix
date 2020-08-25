{}:
let
  inherit (import ./nix) pkgs sources;
  inherit (pkgs) lib;

  updater = { version }: pkgs.writeShellScriptBin "update" ''
    set -u

    ${lib.concatStrings (lib.mapAttrsToList (name: nixpkgs:
      let
        image = pkgs.callPackage ./image.nix { inherit nixpkgs version; };
        nameTag = "nixpkgs-${nixpkgs.branch}:${nixpkgs.rev}";
        dest = "docker://docker.io/$REGISTRY_USER/${nameTag}";
      in ''
        echo "=== Image ${dest} ==="
        echo "Checking whether the image needs to be updated.." >&2
        echo "Inspecting whether the image already exists.." >&2
        if inspectionJson=$(${pkgs.skopeo}/bin/skopeo inspect --creds "$REGISTRY_USER:$REGISTRY_PASSWORD" "${dest}"); then
          version=$(${pkgs.jq}/bin/jq -r '.Labels.DockerNixpkgsVersion' <<< "$inspectionJson")
          if [[ "$version" == "${version}" ]]; then
            echo "Image does exist and it uses the current version of docker-nixpkgs already" >&2
            needsUpdate=0
          else
            echo "Image does exist and it uses the outdated version $version of docker-nixpkgs" >&2
            needsUpdate=1
          fi
        else
          # TODO: Check whether it doesn't exist or if it's another error
          echo "Error inspecting the image, assuming it doesn't exist" >&2
          needsUpdate=1
        fi

        if [[ "$needsUpdate" == 0 ]]; then
          echo "Image doesn't need to be updated" >&2
        else

          # TODO: This here makes it depend on the nixpkgs source
          # Refactor to only need that if we actually need to push an update
          echo "Building the image.." >&2
          if ! out=$(nix-build --no-out-link ${builtins.unsafeDiscardStringContext image.drvPath}); then
            echo "Error building the image" >&2

          else
            echo "Image built successfully" >&2

            echo "Pushing the image.." >&2
            src=docker-archive://$out
            if ! ${pkgs.skopeo}/bin/skopeo copy --dest-creds "$REGISTRY_USER:$REGISTRY_PASSWORD" "$src" "${dest}"; then
              echo "Error pushing the image" >&2
            else
              echo "Successfully pushed the image" >&2
            fi
          fi
        fi

        echo ""
      ''
    ) sources)}
  '';

in {
  devShell = pkgs.mkShell {
    buildInputs = [
      pkgs.niv
    ];
  };
  inherit updater pkgs sources;
}
