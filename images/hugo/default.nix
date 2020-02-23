{ buildCLIImage
, hugo
, gitReallyMinimal
}:
buildCLIImage {
  drv = hugo;
  extraContents = [ gitReallyMinimal ];
}
