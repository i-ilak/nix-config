{ config
, pkgs
, lib
, home-manager
, ...
}:
let
  user = "iilak";
  sharedModules = import ../../modules/shared/home-manager.nix { inherit pkgs config lib user; };
  sharedFiles = import ../shared/files.nix { inherit config pkgs lib; };
  additionalFiles = import ./files.nix { inherit user config pkgs; };
in
{
  imports = [
    ../../modules/darwin/dock
    ../../modules/darwin/aerospace.nix
  ];

  users.users.${user} = {
    name = "${user}";
    home = "/Users/${user}";
    isHidden = false;
    shell = pkgs.zsh;
  };

  homebrew = {
    # This is a module from nix-darwin
    # Homebrew is *installed* via the flake input nix-homebrew
    enable = true;
    casks = pkgs.callPackage ./casks.nix { };

    taps = [
      "nikitabobko/tap"
    ];

    # These app IDs are from using the mas CLI app
    # mas = mac app store
    # https://github.com/mas-cli/mas
    #
    # $ nix shell nixpkgs#mas
    # $ mas search <app name>
    #
    masApps = {
      "strongbox" = 897283731;
      "reader" = 1529448980;
      "whatsapp" = 310633997;
    };
  };

  # Enable home-manager
  home-manager = {
    useGlobalPkgs = true;
    users.${user} =
      { pkgs
      , config
      , lib
      , ...
      }: {
        home = {
          enableNixpkgsReleaseCheck = false;
          packages = pkgs.callPackage ./packages.nix { };
          file = lib.mkMerge [
            sharedFiles
            additionalFiles
          ];

          stateVersion = "24.05";
        };
        programs = { } // sharedModules;

        # Marked broken Oct 20, 2022 check later to remove this
        # https://github.com/nix-community/home-manager/issues/3344
        manual.manpages.enable = false;
      };
  };

  # Fully declarative dock using the latest from Nix Store
  local = {
    dock.enable = true;
    dock.entries = [
      { path = "/Applications/Safari.app/"; }
    ];
  };
}
