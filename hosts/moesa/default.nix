{
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    inputs.disko.nixosModules.disko
    ./disk-config.nix
    # Hardening
    ../../modules/nixos/locale.nix
    ../../modules/nixos/hardening/audit.nix
    ../../modules/nixos/hardening/sudo.nix
    ../../modules/nixos/hardening/no-defaults.nix
    ../../modules/nixos/hardening/noexec.nix
    # Configuration
    ../../modules/shared/networking.nix
    ./additional_config_parameters.nix
    ./networking.nix
    ./sshd.nix
    ./share.nix
  ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  nix.settings.allowed-users = [ "root" ];

  environment.systemPackages = with pkgs; [
    vim
    rsync
    tree
  ];

  # DO NOT CHANGE, EVER.
  # Needs to be the version of the installer that was used to install the initial version of NixOS
  system.stateVersion = "25.05";
}
