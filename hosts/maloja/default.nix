{
  inputs,
  pkgs,
  config,
  ...
}:
{
  imports = [
    inputs.disko.nixosModules.disko
    inputs.impermanence.nixosModules.impermanence
    inputs.authentik-nix.nixosModules.default
    ./additional_config_parameters.nix
    ./disk-config.nix
    ./boot.nix
    ./impermanance.nix
    ./sops.nix
    # ./tailscale.nix
    ./acme.nix
    ./caddy.nix
    # Hardening
    ../../modules/nixos/locale.nix
    ../../modules/nixos/hardening/audit.nix
    ../../modules/nixos/hardening/sudo.nix
    ../../modules/nixos/hardening/no-defaults.nix
    ../../modules/nixos/hardening/noexec.nix
    ./sshd.nix
    # Services
    ./jellyfin.nix
    ./ytdl-sub.nix
    ./home-assistant.nix
    ./paperless.nix
    ./adguard_home.nix
    ./unbound.nix
    # ./authentik.nix
    # ./authelia.nix
  ];

  networking = {
    hostName = config.sharedVariables.hostname;
    firewall = {
      enable = true;
      allowedTCPPorts = [
        80
        443
        53 # DNS (AdGuard Home)
      ];
      allowedUDPPorts = [
        53 # DNS (AdGuard Home)
        67 # DHCP (AdGuard Home)
        68 # DHCP (AdGuard Home)
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
      # paperless = {
      #   isSystemUser = true;
      #   group = "paperless";
      #   extraGroups = [ "backup" ];
      # };
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
    nss
    # inputs.ha-cli.packages.${pkgs.system}.default
  ];

  # DO NOT CHANGE, EVER.
  # Needs to be the version of the installer that was used to install the initial version of NixOS
  system.stateVersion = "25.05";
}
