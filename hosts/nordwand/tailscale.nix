{
  config,
  ...
}:
{
  services.tailscale = {
    enable = true;
    authKeyFile = config.sops.secrets.tailscale_auth_key.path;
    extraUpFlags = [ "--advertise-tags=tag:vault-server" ];
  };

  networking.firewall = {
    trustedInterfaces = [ "tailscale0" ];
    allowedUDPPorts = [ config.services.tailscale.port ];
  };
}
