{
  config,
  ...
}:
{
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      80
      443
    ];
  };

  # Enable local DNS resolution
  services.dnsmasq = {
    enable = true;
    settings = {
      interface = "lo,ens160";
      bind-interfaces = true;
      address = [
        "/jellyfin.maloja.local/${config.sharedVariables.ip}"
        "/homeassistant.maloja.local/${config.sharedVariables.ip}"
        "/paperless.maloja.local/${config.sharedVariables.ip}"
        "/authelia.maloja.local/${config.sharedVariables.ip}"
      ];

      domain-needed = true;
      bogus-priv = true;
      cache-size = 1000;
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
