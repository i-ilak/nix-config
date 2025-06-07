{ inputs
, pkgs
, config
, lib
, ...
}:
let
  user = "iilak";
  hostname = "pilatus";
  shared-files = import ../../modules/shared/files.nix { inherit config pkgs lib; };
in
{
  imports = [
    inputs.disko.nixosModules.disko
    ./disk-config.nix
    ../../modules/shared
    ../../modules/shared/cachix
  ];

  boot = {
    loader = {
      grub = {
        enable = true;
        efiSupport = true;
        efiInstallAsRemovable = true;
      };
    };
  };

  networking = {
    networkmanager.enable = true; # Easiest to use and most distros use this by default.
    hostName = hostname;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 80 443 22022 ];
    };
  };

  time.timeZone = "Europe/Amsterdam";
  i18n.defaultLocale = "en_US.UTF-8";

  nix = {
    nixPath = [ "nixos-config=/home/${user}/.local/share/src/nixos-config:/etc/nixos" ];
    settings.allowed-users = [ "${user}" ];
    package = pkgs.nix;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  programs = {
    fish.enable = true;
  };

  hardware = {
    graphics = {
      enable = true;
    };
  };

  virtualisation = { };

  users.users = {
    ${user} = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
      ];
      shell = pkgs.fish;
    };
  };

  security.sudo = {
    enable = true;
    extraRules = [
      {
        commands = [
          {
            command = "${pkgs.systemd}/bin/reboot";
            options = [ "NOPASSWD" ];
          }
        ];
        groups = [ "wheel" ];
      }
    ];
  };

  fonts = {
    fontDir.enable = true;
    enableGhostscriptFonts = true;
    packages = with pkgs; [
      meslo-lgs-nf
      dejavu_fonts
      jetbrains-mono
      font-awesome
      noto-fonts
      noto-fonts-emoji
    ];
  };

  environment.systemPackages = with pkgs; [
    gitAndTools.gitFull
    linuxPackages.v4l2loopback
    v4l-utils
    inetutils
    vim
  ];

  system.stateVersion = "25.05";
}
