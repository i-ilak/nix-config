{
  pkgs,
  ...
}:
{
  imports = [
    # inputs.disko.nixosModules.disko
    # ./disko-config.nix
    ./hardware-configuration.nix
    # Hardening
    ../../modules/nixos/locale.nix
    ../../modules/nixos/hardening/audit.nix
    ../../modules/nixos/hardening/sudo.nix
    ../../modules/nixos/hardening/no-defaults.nix
    # Configuration
    ../../modules/shared/networking.nix
    ./additional_config_parameters.nix
    ./sops.nix
    ./user_setup.nix
    ./networking.nix
    ./sshd.nix
    ./acme_certs_sync.nix
    # Services
    ./adguard_home.nix
    ./unbound.nix
    ./unifi.nix
    ./caddy.nix
  ];

  nix.settings.allowed-users = [ "root" ];

  environment.systemPackages = with pkgs; [
    neovim
    restic
    jq
    rsync
  ];

  # DO NOT CHANGE, EVER.
  # Needs to be the version of the installer that was used to install the initial version of NixOS
  system.stateVersion = "25.05";
}
