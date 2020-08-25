{}:
let
  inherit (import ./nix) pkgs sources;
  inherit (pkgs) lib;

  updater = pkgs.writeShellScriptBin "update" ''
    set -u

    ${lib.concatStrings (lib.mapAttrsToList (name: nixpkgs:
      let
        image = pkgs.callPackage ./image.nix { inherit nixpkgs; };
        nameTag = "nixpkgs-${nixpkgs.branch}:${nixpkgs.rev}";
        dest = "docker://docker.io/$REGISTRY_USER/${nameTag}";
      in ''
        echo "=== Image ${dest} ==="
        echo "Inspecting whether the image already exists.." >&2
        if ${pkgs.skopeo}/bin/skopeo inspect --creds "$REGISTRY_USER:$REGISTRY_PASSWORD" "${dest}"; then
          # TODO: Compare hashes, so updates that don't change the channel can be pushed
          echo "Image does exist, no update necessary" >&2

        else
          # TODO: Check whether it doesn't exist or if it's another error
          echo "Error inspecting the image, assuming it doesn't exist" >&2

          # TODO: This here makes it depend on the nixpkgs source
          # Refactor to only need that if we actually need to push an update
          echo "Building the image.." >&2
          if ! nix-build ${builtins.unsafeDiscardStringContext image.drvPath}; then
            echo "Error building the image" >&2

          else
            echo "Image built successfully" >&2

            echo "Pushing the image.." >&2
            src=docker-archive://$PWD/result
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
  inherit updater;

  inherit pkgs;
}
