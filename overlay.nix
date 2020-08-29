final: prev: {

  scripts = prev.callPackage ./scripts {};

  # gitMinimal still ships with perl and python
  gitReallyMinimal = (
    prev.git.override {
      perlSupport = false;
      pythonSupport = false;
      withManual = false;
      withpcre2 = false;
    }
  ).overrideAttrs (
    _: {
      # installCheck is broken when perl is disabled
      doInstallCheck = false;
    }
  );

}
