{
  inputs,
  ...
}:
{
  imports = [
    inputs.disko.nixosModules.disko
    ./disk-config.nix
    # Hardening
    ./system.nix
    ../../modules/nixos/locale.nix
    ../../modules/nixos/hardening/audit.nix
    ../../modules/nixos/hardening/sudo.nix
    ../../modules/nixos/hardening/no-defaults.nix
    ../../modules/nixos/hardening/noexec.nix
    ../../modules/nixos/hardening/usbguard.nix
    # Configuration
    ../../modules/shared/global_variables
    ./additional_config_parameters.nix
    ./sops.nix
    ./networking.nix
    ./sshd.nix
    ./share.nix
  ];

  # DO NOT CHANGE, EVER.
  # Needs to be the version of the installer that was used to install the initial version of NixOS
  system.stateVersion = "25.05";
}
