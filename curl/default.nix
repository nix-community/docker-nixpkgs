{ buildCLIImage
, curl
}:
buildCLIImage {
  drv = curl;
}
