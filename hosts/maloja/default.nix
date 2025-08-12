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
    ./additional_config_parameters.nix
    ./disk-config.nix
    ./boot.nix
    ./impermanance.nix
    ./sops.nix
    ./tailscale.nix
    # Hardening
    ./locale.nix
    ./audit.nix
    ./sudo.nix
    ./no-defaults.nix
    ./noexec.nix
    ./sshd.nix
    # Services
    ./jellyfin.nix
    ./ytdl-sub.nix
    ./home-assistant.nix
    ./paperless.nix
    ./restic.nix
  ];

  networking = {
    hostName = "maloja";
    firewall = {
      enable = true;
      allowedTCPPorts = [ 8123 ];
    };
  };

  users = {
    groups.media = { };
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
