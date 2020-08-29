{ writeShellScriptBin, writeShellScript, lib
, skopeo, gnused, jq
}: {

  exportProfile = writeShellScriptBin "export-profile" (builtins.readFile ./export-profile);

  image-update = writeShellScript "image-update" ''
    export PATH=${lib.makeBinPath [ skopeo jq ]}:$PATH
    ${builtins.readFile ./image-update}
  '';

  run-tests = writeShellScript "run-tests" ''
    export PATH=${lib.makeBinPath [ gnused jq ]}:$PATH
    ${builtins.readFile ./run-tests}
  '';

}
