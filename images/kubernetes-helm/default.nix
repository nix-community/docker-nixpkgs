{ buildCLIImage
, kubernetes-helm
}:
buildCLIImage {
  drv = kubernetes-helm;
  binName = "helm";
}
