{
  config,
  ...
}:
{
  services.tailscale = {
    enable = true;
    authKeyFile = config.sops.secrets.tailscale_auth_key.path;
    extraUpFlags = [ "--advertise-tags=tag:isolated" ];
  };

  networking.firewall = {
    trustedInterfaces = [ "tailscale0" ];
    allowedUDPPorts = [ config.services.tailscale.port ];
  };
}
