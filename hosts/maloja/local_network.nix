{
  config,
  ...
}:
{
  # Enable local DNS resolution
  services.dnsmasq =
    let
      inherit (config.sharedVariables) baseDomain;
    in
    {
      enable = true;
      resolveLocalQueries = true;
      settings = {
        "expand-hosts" = true;
        address = [
          "/paperless.${baseDomain}/${config.sharedVariables.ip}"
          "/home.${baseDomain}/${config.sharedVariables.ip}"
          "/jellyfin.${baseDomain}/${config.sharedVariables.ip}"
          "/auth.${baseDomain}/${config.sharedVariables.ip}"
        ];
      };
    };

  # Enable mDNS for easier discovery
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
      domain = true;
      hinfo = true;
      userServices = true;
      workstation = true;
    };
  };
}
