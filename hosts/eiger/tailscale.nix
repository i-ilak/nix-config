{ config, ... }:
{
  services.tailscale.enable = true;

  # Tell the firewall implicitly to trust packated routed over Tailscale:
  networking.firewall = {
    trustedInterfaces = [ "tailscale0" ];
    allowedUDPPorts = [ config.services.tailscale.port ];
  };
}
