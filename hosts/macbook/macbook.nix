{ pkgs
, inputs
, config
, lib
, ...
}:
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

  home-manager = {
    useGlobalPkgs = true;
    users.${config.sharedVariables.user} = import ./home.nix { inherit pkgs inputs lib config; };
  };

  programs.fish.enable = true;
  users.users.${config.sharedVariables.user} = {
    name = "${config.sharedVariables.user}";
    home = "/Users/${config.sharedVariables.user}";
    isHidden = false;
    shell = pkgs.fish;
  };

  services = {
    nix-daemon.enable = true;
    tailscale.enable = true;
  };

  nix =
    let
      inherit (config.sharedVariables) user;
    in
    {
      package = pkgs.nix;
      settings.trusted-users = [ "@admin" "${user}" ];

      gc = {
        user = "root";
        automatic = true;
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

  environment.systemPackages = import ../../modules/shared/system_packages.nix { inherit pkgs; };
  security.pam.enableSudoTouchIdAuth = true;
  system = import ../../modules/darwin/system.nix { inherit config; };

  local = {
    dock = {
      enable = true;
      entries = [
        { path = "/Applications/Safari.app/"; }
      ];
    };
    desktoppr = {
      enable = true;
      wallpapers = [
        {
          desktop = 0;
          name = "red_devil";
        }
      ];
    };
  };
}
