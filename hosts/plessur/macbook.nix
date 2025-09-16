{
  pkgs,
  inputs,
  config,
  lib,
  ...
}:
let
  inherit (config.sharedVariables) user;
  inherit (config.sharedVariables) homeDir;
in
{
  imports = [
    ./additional_config_parameters.nix
    ../../modules/darwin/homebrew.nix
    ../../modules/darwin/dock
    ../../modules/darwin/desktoppr
    #../../modules/darwin/aerospace.nix
    ../../modules/shared
    ../../modules/shared/cachix
  ];

  ids.gids.nixbld = 350;

  home-manager = {
    useGlobalPkgs = true;
    users.${user} = import ./home.nix {
      inherit
        pkgs
        inputs
        lib
        config
        ;
    };
  };

  programs.fish.enable = true;
  users.users.${user} = {
    name = "${user}";
    home = "${homeDir}";
    isHidden = false;
    shell = pkgs.fish;
  };

  services = {
    tailscale.enable = true;
  };

  # Use when nix installed with `determinated`
  determinate-nix.customSettings = {
    trusted-users = [
      "${user}"
    ];
  };

  # Use when nix installed without `determinated`
  nix =
    let
      inherit (config.sharedVariables) user;
    in
    {
      enable = false;
      package = pkgs.nix;
      settings = {
        trusted-users = [
          "@admin"
          "${user}"
        ];
        extra-platforms = [
          "aarch64-darwin"
          "aarch64-linux"
          "x86_64-linux"
        ];
      };

      gc = {
        automatic = false;
        interval = {
          Weekday = 0;
          Hour = 2;
          Minute = 0;
        };
        options = "--delete-older-than 10d";
      };

      # Turn this on to make command line easier
      extraOptions = ''
        experimental-features = nix-command flakes
      '';
    };

    gc = {
      automatic = true;
      interval = {
        Weekday = 0;
        Hour = 2;
        Minute = 0;
      };
      options = "--delete-older-than 10d";
    };

    linux-builder = {
      enable = true;
      ephemeral = true;
      maxJobs = 4;
      config = {
        virtualisation = {
          darwin-builder = {
            diskSize = 40 * 1024;
            memorySize = 8 * 1024;
          };
          cores = 6;
        };
      };
    };
  };

  environment.systemPackages = import ../../modules/shared/system_packages.nix { inherit pkgs; };
  security.pam.services.sudo_local.touchIdAuth = true;
  system = import ../../modules/darwin/system.nix { inherit config; };

  fonts.packages = with pkgs; [
    meslo-lgs-nf
    nerd-fonts.jetbrains-mono
  ];

  local =
    let
      inherit (config.sharedVariables) user;
    in
    {
      dock = {
        enable = true;
        entries = [
          { path = "/Applications/Firefox.app/"; }
        ];
        username = "${user}";
      };
      desktoppr = {
        enable = true;
        wallpapers = [
          {
            desktop = 0;
            name = "red_devil";
          }
        ];
        username = "${user}";
      };
    };
}
