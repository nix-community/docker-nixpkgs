{ lib }:

importFn: baseDir:
let
  dirEntries =
    builtins.attrNames
      (
        lib.filterAttrs
          (k: v: v == "directory")
          (builtins.readDir baseDir)
      );

  absDirs =
    builtins.map
      (dir: "${toString baseDir}/${dir}")
      dirEntries;

  imports =
    builtins.map
      (dir: { name = builtins.baseNameOf dir; value = importFn dir; })
      absDirs;
in
builtins.listToAttrs imports
