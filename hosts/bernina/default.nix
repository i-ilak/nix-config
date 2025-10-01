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
    ./sshd.nix
    # Services
    ./adguard_home.nix
    ./unbound.nix
  ];

  networking = {
    hostName = config.sharedVariables.hostname;
    firewall = {
      enable = true;
      allowedTCPPorts = [
        80
        443
        53 # DNS
      ];
      allowedUDPPorts = [
        53 # DNS
        67 # DHCP
        68 # DHCP
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
      backup = { };
    };
    mutableUsers = false;
    users = {
      root.hashedPasswordFile = config.sops.secrets."user-root-password".path;
      worker = {
        hashedPasswordFile = config.sops.secrets."user-worker-password".path;
        isNormalUser = true;
        extraGroups = [
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
    libraspberrypi
    raspberrypi-eeprom
  ];

  # DO NOT CHANGE, EVER.
  # Needs to be the version of the installer that was used to install the initial version of NixOS
  system.stateVersion = "25.05";
}
