{ buildCLIImage
, kubectl
}:
buildCLIImage {
  drv = kubectl;
}
