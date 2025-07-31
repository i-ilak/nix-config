{
  config,
  ...
}:
{
  sops.secrets = {
    cloudflared_homelab_tunnel_id = {
      key = "cloudflared/homelab/tunnel_id";
      owner = "cloudflared";
      group = "cloudflared";
      mode = "0400";
    };
    cloudflared_homelab_account_tag = {
      key = "cloudflared/homelab/account_tag";
      owner = "cloudflared";
      group = "cloudflared";
      mode = "0400";
    };
    cloudflared_homelab_tunnel_secret = {
      key = "cloudflared/homelab/tunnel_secret";
      owner = "cloudflared";
      group = "cloudflared";
      mode = "0400";
    };
  };
  sops.templates."cloudflared_credentials.json" = {
    content = ''
      {
        "AccountTag": "${config.sops.placeholder.cloudflared_homelab_account_tag}",
        "TunnelID": "${config.sops.placeholder.cloudflared_homelab_tunnel_id}",
        "TunnelSecret": "${config.sops.placeholder.cloudflared_homelab_tunnel_secret}",
        "Endpoint":""
      }
    '';
    owner = "cloudflared";
  };

  services.cloudflared = {
    enable = true;
    tunnels."homelab" = {
      credentialsFile = config.sops.templates."cloudflared_credentials.json".path;
      default = "http_status:404";
      ingress = {
        "auth.${config.sharedVariables.domain}" = {
          service = "https://127.0.0.1:443";
          originRequest = {
            originServerName = "auth.${config.sharedVariables.domain}";
            caPool = config.sops.secrets.cloudflare_authenticated_origin_pull_ca.path;
          };
        };
        "home.${config.sharedVariables.domain}" = {
          service = "https://127.0.0.1:443";
          originRequest = {
            originServerName = "home.${config.sharedVariables.domain}";
            caPool = config.sops.secrets.cloudflare_authenticated_origin_pull_ca.path;
          };
        };
      };
    };
  };

  systemd.services.cloudflared-tunnel-homelab = {
    serviceConfig = {
      User = "cloudflared";
      SupplementaryGroups = [ "origin_pull" ];
    };
  };
}
