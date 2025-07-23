{
  config,
  ...
}:
{
  sops.secrets.tailscale_auth_key = {
    owner = "root";
    group = "root";
    mode = "0400";
  };

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
