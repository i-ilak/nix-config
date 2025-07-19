{
  inputs,
  config,
  ...
}:
let
  secretspath = builtins.toString inputs.nix-secrets;
  certloc = "/var/lib/acme/vault.iilak.com";
in
{
  # READ: https://aottr.dev/posts/2024/08/homelab-setting-up-caddy-reverse-proxy-with-ssl-on-nixos/
  imports = [
    inputs.disko.nixosModules.disko
    inputs.impermanence.nixosModules.impermanence
    ./disk-config.nix
    ./boot.nix
    ./impermanance.nix
    ./networking.nix
    ./sops.nix
    ../../modules/nixos/locale.nix
    ../../modules/nixos/hardening/audit.nix
    ../../modules/nixos/hardening/sudo.nix
    ../../modules/nixos/hardening/no-defaults.nix
    ../../modules/nixos/hardening/noexec.nix
    ./sshd.nix
    ./tailscale.nix
  ];

  users = {
    groups.cloudflared = { };
    mutableUsers = false;
    users = {
      root.hashedPasswordFile = config.sops.secrets."user-root-password".path;
      cloudflared = {
        isSystemUser = true;
        group = "cloudflared";
      };
    };
  };

  nix.settings.allowed-users = [ "root" ];

  sops = {
    defaultSopsFile = "${secretspath}/secrets/nordwand.yaml";
    age = {
      sshKeyPaths = [ "/persist/etc/ssh/ssh_host_ed25519_key" ];
    };
    secrets = {
      user-root-password = {
        key = "user/root/password";
        owner = "root";
        group = "root";
        mode = "0400";
        neededForUsers = true;
      };
      tailscale_auth_key = {
        owner = "root";
        group = "root";
        mode = "0400";
      };
      cloudflared_test_tunnel_id = {
        key = "cloudflared/test/tunnel_id";
        owner = "cloudflared";
        group = "cloudflared";
        mode = "0400";
      };
      cloudflared_test_account_id = {
        key = "cloudflared/test/account_id";
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
      cloudflared_dns_api_token = {
        key = "cloudflared/dns_api_token";
        owner = "root";
        group = "root";
        mode = "0400";
      };
    };
  };

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

  sops.templates."cloudflared_dns_api_token" = {
    content = ''
      CLOUDFLARE_DNS_API_TOKEN=${config.sops.placeholder.cloudflared_dns_api_token}
    '';
    owner = "root";
  };

  services = {
    vaultwarden = {
      enable = true;
      dbBackend = "sqlite";
      config = {
        ROCKET_ADDRESS = "127.0.0.1";
        ROCKET_PORT = 8000;
        DOMAIN = "[https://vault.ilak.ch](https://vault.ilak.ch)";
        SIGNUPS_ALLOWED = false;
        WEBSOCKET_ENABLED = true;
        ADMIN_TOKEN = "your-secure-admin-token-hash"; # IMPORTANT: Generate with `vaultwarden hash`
        LOG_FILE = "/var/log/vaultwarden/vaultwarden.log";
        LOG_LEVEL = "info";
      };
    };
    caddy = {
      enable = true;
      group = "caddy";
      virtualHosts."vault.ilak.ch" = {
        # Caddy will bind to 0.0.0.0:80 and 0.0.0.0:443 for public access
        # including ACME challenges.
        extraConfig = ''
          reverse_proxy 127.0.0.1:${toString config.services.vaultwarden.config.ROCKET_PORT} {
            header_up Host {host}
            header_up X-Real-IP {remote_ip}
            header_up X-Forwarded-For {remote_ip}
            header_up X-Forwarded-Proto {scheme}
          }

          tls ${certloc}/cert.pem ${certloc}/key.pem {
            protocols tls1.3
          }
        '';
      };
    };
    cloudflared = {
      enable = true;
      tunnels."vault-tunnel" = {
        credentialsFile = config.sops.templates."cloudflared_credentials.json".path;
        default = "http_status:404";
        ingress = {
          "vault.example.com" = "https://YOUR_TAILSCALE_IP:443";
        };
      };
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "your@email.com";

    certs."your.domain.com" = {
      inherit (config.services.caddy) group;
      domain = "your.domain.com";
      extraDomainNames = [ "*.your.domain.com" ];
      dnsProvider = "cloudflare";
      dnsResolver = "1.1.1.1:53";
      dnsPropagationCheck = true;
      environmentFile = config.sops.templates."cloudflared_dns_api_token".path;
    };
  };

  # DO NOT CHANGE, EVER.
  # Needs to be the version of the installer that was used to install the initial version of NixOS
  system.stateVersion = "25.05"; # Did you read the comment?
}
