{
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    # Hardening
    # ./impermanance.nix
    ../../modules/nixos/locale.nix
    ../../modules/nixos/hardening/audit.nix
    ../../modules/nixos/hardening/sudo.nix
    ../../modules/nixos/hardening/no-defaults.nix
    # ../../modules/nixos/hardening/noexec.nix
    # Configuration
    ./additional_config_parameters.nix
    ../../modules/shared/networking.nix
    ./sops.nix
    ./user_setup.nix
    ./networking.nix
    ./sshd.nix
    ./acme_certs_sync.nix
    # Services
    ./adguard_home.nix
    ./unbound.nix
    ./unifi.nix
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
