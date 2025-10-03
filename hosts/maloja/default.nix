{
  inputs,
  pkgs,
  config,
  ...
}:
{
  imports = [
    inputs.disko.nixosModules.disko
    ./disk-config.nix
    # Hardening
    ./impermanance.nix
    ../../modules/nixos/locale.nix
    ../../modules/nixos/hardening/audit.nix
    ../../modules/nixos/hardening/sudo.nix
    ../../modules/nixos/hardening/no-defaults.nix
    ../../modules/nixos/hardening/noexec.nix
    # Configuration
    ./additional_config_parameters.nix
    ./sops.nix
    # ./tailscale.nix
    ./acme.nix
    ./caddy.nix
    ./sshd.nix
    # Services
    ./jellyfin.nix
    ./ytdl-sub.nix
    ./home-assistant.nix
    ./paperless.nix
    ./atticd.nix
    # ./authentik.nix
    # ./authelia.nix
    ./unifi.nix
  ];

  networking = {
    hostName = config.sharedVariables.hostname;
    firewall = {
      enable = true;
      allowedTCPPorts = [
        80
        443
      ];
    };
    defaultGateway = {
      address = "${config.sharedVariables.gatewayIp}";
    };
    useDHCP = false;
    interfaces."enp89s0" = {
      ipv4 = {
        addresses = [
          {
            address = "${config.sharedVariables.ip}";
            prefixLength = 24;
          }
        ];
      };
    };
  };

  users = {
    groups = {
      media = { };
      backup = { };
      atticd = { };
    };
    mutableUsers = false;
    users = {
      root.hashedPasswordFile = config.sops.secrets."user-root-password".path;
      worker = {
        hashedPasswordFile = config.sops.secrets."user-worker-password".path;
        isNormalUser = true;
        extraGroups = [
          "media"
          "systemd-journal"
        ];
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDKU+/RXjWLUzfRgMIhWnI4LD9Zh11BmCJsFaYNZNQqg"
        ];
      };
      atticd = {
        isSystemUser = true;
        group = "atticd";
      };
    };
  };

  nix.settings = {
    substituters = [
      "https://cache.nix.${config.sharedVariables.publicDomain}"
    ];
    allowed-users = [ "root" ];
  };

  environment.systemPackages = with pkgs; [
    neovim
    rsync
    tree
    vim
    git
    jellyfin
    jellyfin-web
    jellyfin-ffmpeg
  ];

  # DO NOT CHANGE, EVER.
  # Needs to be the version of the installer that was used to install the initial version of NixOS
  system.stateVersion = "25.05";
}
