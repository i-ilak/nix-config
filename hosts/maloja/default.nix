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
    ./disk-config.nix
    ./boot.nix
    ./impermanance.nix
    ./home-assistant.nix
    ./sops.nix
    ./locale.nix
    ./audit.nix
    ./sudo.nix
    ./no-defaults.nix
    ./noexec.nix
    ./sshd.nix
    ./jellyfin.nix
    ./tailscale.nix
  ];

  networking = {
    hostName = "maloja";
    firewall = {
      enable = true;
      allowedTCPPorts = [ 8123 ];
    };
  };

  virtualisation.vmware.guest.enable = true;

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
  system.stateVersion = "25.05"; # Did you read the comment?
}
