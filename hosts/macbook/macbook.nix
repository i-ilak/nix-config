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
    ../../modules/darwin/aerospace.nix
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

  nix = {
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
      experimental-features = [
        "nix-command"
        "flakes"
      ];
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

  local =
    let
      inherit (config.sharedVariables) user;
    in
    {
      dock = {
        enable = true;
        entries = [
          { path = "/Applications/Safari.app/"; }
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
