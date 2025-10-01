{
  inputs,
  ...
}:
{
  services.unifi =
    let
      # We pin the dependencies since they seem to be a huge pain to manage
      unifi-nixpkgs = import inputs.unifi-controller {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
    in
    {
      enable = true;
      unifiPackage = unifi-nixpkgs.unifi;
      mongodbPackage = unifi-nixpkgs.mongodb;
      jrePackage = unifi-nixpkgs.jre;
    };
}
