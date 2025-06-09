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
  sharedPackages = import ../../modules/shared/system_packages.nix { inherit pkgs; };
in
{
  imports = [
    inputs.disko.nixosModules.disko
    ./disk-config.nix
    ./additional_config_parameters.nix
    ../../modules/shared
    ../../modules/shared/cachix
  ];

  home-manager = {
    useGlobalPkgs = true;
    users.${config.sharedVariables.user} = import ./home.nix { inherit pkgs inputs lib config; };
  };

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
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

  virtualisation = {
    vmware.guest.enable = true;
  };

  services = {
    displayManager = {
      defaultSession = "none+i3";
    };

    xserver = {
      enable = true;

      resolutions = [
        {
          x = 1920;
          y = 1200;
        }
      ];

      desktopManager = {
        xterm.enable = false;
      };

      windowManager.i3 = {
        enable = true;
        extraPackages = with pkgs; [
          dmenu
          i3status
          i3lock
          i3blocks
        ];
      };
    };
  };

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
  ] ++ sharedPackages;

  # Do not change this, ever
  system.stateVersion = "25.05";
}
