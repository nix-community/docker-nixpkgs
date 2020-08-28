{ writeShellScriptBin, skopeo, jq, lib }: {

  exportProfile = writeShellScriptBin "export-profile" (builtins.readFile ./export-profile);
  singleImageUpdater = writeShellScriptBin "update" ''
    export PATH=${lib.makeBinPath [ skopeo jq ]}:$PATH
    ${builtins.readFile ./image-update}
  '';

}
