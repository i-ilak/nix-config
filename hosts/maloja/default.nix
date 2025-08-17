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
    ./tailscale.nix
    ./caddy.nix
    ./local_network.nix
    # Hardening
    ../../modules/nixos/locale.nix
    ../../modules/nixos/hardening/audit.nix
    ../../modules/nixos/hardening/sudo.nix
    ../../modules/nixos/hardening/no-defaults.nix
    ../../modules/nixos/hardening/noexec.nix
    ./sshd.nix
    # Services
    # ./jellyfin.nix
    # ./ytdl-sub.nix
    # ./home-assistant.nix
    ./paperless.nix
    ./restic.nix
    # ./authentik.nix
    # ./authelia.nix
  ];

  networking = {
    hostName = config.sharedVariables.hostname;
    firewall = {
      enable = false;
      allowedTCPPorts = [
        80
        443
        53 # dnsmasq
        config.sharedVariables.authelia.port
        config.sharedVariables.paperless.port
        config.sharedVariables.home-assistant.port
      ];
      allowedUDPPorts = [ 53 ];
    };
  };

  users = {
    groups = {
      media = { };
      authentik = { };
    };
    mutableUsers = false;
    users = {
      root.hashedPasswordFile = config.sops.secrets."user-root-password".path;
      worker = {
        hashedPasswordFile = config.sops.secrets."user-worker-password".path;
        isNormalUser = true;
        extraGroups = [ "media" ];
      };
      authentik = {
        isSystemUser = true;
        group = "authentik";
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
