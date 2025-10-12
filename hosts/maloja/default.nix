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
    ./impermanance.nix
    ../../modules/nixos/locale.nix
    ../../modules/nixos/hardening/audit.nix
    ../../modules/nixos/hardening/sudo.nix
    ../../modules/nixos/hardening/no-defaults.nix
    ../../modules/nixos/hardening/noexec.nix
    # Configuration
    ../../modules/shared/global_variables
    ./additional_config_parameters.nix
    ./sops.nix
    ./networking.nix
    ./user_setup.nix
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
