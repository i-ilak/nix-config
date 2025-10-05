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
    ../../modules/shared/networking.nix
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
    # ./authentik.nix
    # ./authelia.nix
  ];

  networking = {
    inherit (config.sharedVariables) hostName;
    firewall = {
      enable = true;
      allowedTCPPorts = [
        80
        443
      ];
    };
    defaultGateway = {
      address = "${config.networkLevelVariables.gatewayIp}";
    };
    useDHCP = false;
    interfaces."enp89s0" = {
      ipv4 = {
        addresses = [
          {
            address = "${config.networkLevelVariables.ipMap.${config.networking.hostName}}";
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
    };
  };

  nix.settings.allowed-users = [ "root" ];

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
