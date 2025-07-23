{
  config,
  ...
}:
{
  sops.secrets = {
    cloudflared_test_tunnel_id = {
      key = "cloudflared/test/tunnel_id";
      owner = "cloudflared";
      group = "cloudflared";
      mode = "0400";
    };
    cloudflared_test_account_tag = {
      key = "cloudflared/test/account_tag";
      owner = "cloudflared";
      group = "cloudflared";
      mode = "0400";
    };
    cloudflared_test_tunnel_secret = {
      key = "cloudflared/test/tunnel_secret";
      owner = "cloudflared";
      group = "cloudflared";
      mode = "0400";
    };
  };
  sops.templates."cloudflared_credentials.json" = {
    content = ''
      {
        "AccountTag": "${config.sops.placeholder.cloudflared_test_account_tag}",
        "TunnelID": "${config.sops.placeholder.cloudflared_test_tunnel_id}",
        "TunnelSecret": "${config.sops.placeholder.cloudflared_test_tunnel_secret}",
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
        "auth.${config.sharedVariables.domain}" = "https://auth.${config.sharedVariables.domain}:443";

        "home.${config.sharedVariables.domain}" = "https://home.${config.sharedVariables.domain}:443";
      };
      originRequest = {
        caPool = config.sops.secrets.cloudflare_authenticated_origin_pull_ca.path;
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
