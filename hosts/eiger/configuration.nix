{ config, lib, pkgs, ... }:
let
  impermanence = builtins.fetchTarball {
    url = "https://github.com/nix-community/impermanence/archive/master.tar.gz";
    sha256 = "0g7qfqajf34dir9gv06ixxgf9hc9nz5ghcpcfdklf1gqhfrapnyh";
  };
in
{
  imports =
    [
      # Include the results of the hardware scan.
      # ./hardware-configuration.nix
      "${impermanence}/nixos.nix"
      ./audit.nix
      ./sudo.nix
      ./no-defaults.nix
      ./noexec.nix
      ./sshd.nix
      ./jellyfin.nix
      ./tailscale.nix
    ];


  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  environment.persistence."/nix/persist" = {
    directories = [
      "/etc/nixos"
      "/passwords"
      "/var/lib"
      "/var/log"
    ];
  };

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  networking = {
    hostName = "eiger";
    firewall.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users = {
    groups.media = { };
    mutableUsers = false;
    users = {
      root.hashedPasswordFile = "/nix/persist/passwords/root";
      worker = {
        hashedPasswordFile = "/nix/persist/passwords/worker";
        isNormalUser = true;
        extraGroups = [ "media" ];
      };
    };
  };

  nix.settings.allowed-users = [ "root" ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    neovim
    rsync
    tree
    jellyfin
    jellyfin-web
    jellyfin-ffmpeg
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # DO NOT CHANGE, EVER
  system.stateVersion = "24.05"; # Did you read the comment?
}

