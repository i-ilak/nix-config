{
  config,
  ...
}:
{
  sops.templates."cloudflared_credentials.json" = {
    content = ''
      {
        "AccountID": "${config.sops.placeholder.cloudflared_test_account_id}",
        "TunnelID": "${config.sops.placeholder.cloudflared_test_tunnel_id}",
        "TunnelSecret": "${config.sops.placeholder.cloudflared_test_tunnel_secret}"
      }
    '';
    owner = "cloudflared";
  };

  services.cloudflared = {
    enable = true;
    tunnels."vault-tunnel" = {
      credentialsFile = config.sops.templates."cloudflared_credentials.json".path;
      default = "http_status:404";
      ingress = {
        "${config.sharedVariables.domain}" = "https://YOUR_TAILSCALE_IP:443";
      };
    };
  };

  systemd.services.cloudflared.unitConfig = {
    After = [ "caddy.service" ];
  };
}
