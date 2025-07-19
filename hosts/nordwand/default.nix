{
  inputs,
  pkgs,
  config,
  ...
}:
let
  secretspath = builtins.toString inputs.nix-secrets;
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
    groups.media = { };
    groups.cloudflared = { };
    mutableUsers = false;
    users = {
      root.hashedPasswordFile = config.sops.secrets."user-root-password".path;
      worker = {
        hashedPasswordFile = config.sops.secrets."user-worker-password".path;
        isNormalUser = true;
        extraGroups = [ "media" ];
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
      tailscale_auth_key = {
        owner = "root";
        group = "root";
        mode = "0400";
      };
      cloudflared_config = {
        owner = "cloudflared";
        group = "cloudflared";
        mode = "0400";
      };
      cloudflared_credentials = {
        owner = "cloudflared";
        group = "cloudflared";
        mode = "0400";
      };
    };
  };

  services.tailscale = {
    enable = true;
    authKeyFile = config.sops.secrets.tailscale_auth_key.path;
    extraUpFlags = [ "--advertise-tags=tag:vault-server" ];
  };

  services.vaultwarden = {
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

  services.caddy = {
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
      '';
    };
  };
  security.acme = {
    acceptTerms = true;
    defaults.email = "your@email.com";

    certs."your.domain.com" = {
      group = config.services.caddy.group;

      domain = "your.domain.com";
      extraDomainNames = [ "*.your.domain.com" ];
      dnsProvider = "cloudflare";
      dnsResolver = "1.1.1.1:53";
      dnsPropagationCheck = true;
      environmentFile = "${pkgs.writeText "cloudflare-creds" ''
        CLOUDFLARE_DNS_API_TOKEN=xxxxxxxxxx
      ''}";
    };
  };

  systemd.services.cloudflared-tunnel = {
    description = "Cloudflare Tunnel for Vaultwarden";
    after = [
      "network.target"
      "tailscale.service"
    ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.cloudflared}/bin/cloudflared tunnel --config ${config.sops.secrets.cloudflared_config.path} run vault-tunnel";
      Restart = "on-failure";
      RestartSec = "5s";
      User = "cloudflared";
      Group = "cloudflared";
      RuntimeDirectory = "cloudflared";
    };
    users = [ "cloudflared" ];
    groups = [ "cloudflared" ];
  };

  # DO NOT CHANGE, EVER.
  # Needs to be the version of the installer that was used to install the initial version of NixOS
  system.stateVersion = "25.05"; # Did you read the comment?
}
