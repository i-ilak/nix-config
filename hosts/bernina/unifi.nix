{
  inputs,
  ...
}:
{
  services.unifi =
    let
      # We pin the dependencies since they seem to be a huge pain to manage
      unifi-nixpkgs = import inputs.unifi-controller {
        system = "aarch64-linux";
        config.allowUnfree = true;
      };
    in
    {
      enable = true;
      unifiPackage = unifi-nixpkgs.unifi;
      mongodbPackage = unifi-nixpkgs.mongodb;
      jrePackage = unifi-nixpkgs.jre_headless;
      initialJavaHeapSize = 512;
      maximumJavaHeapSize = 512;
      openFirewall = true;
    };
}
