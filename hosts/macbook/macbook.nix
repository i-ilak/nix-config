{ pkgs
, inputs
, config
, ...
}:
{
  imports = [
    ./additional_config_parameters.nix
    ./home.nix
    ../../modules/shared
    ../../modules/shared/cachix
  ];

  home-manager.users.${config.sharedVariables.user}.home = {
    packages = [
      inputs.nixvim.packages.${pkgs.system}.default
    ];
    # keyboard.layout = "eu"; # does not seem to do anything
  };

  # Auto upgrade nix package and the daemon service.
  services = {
    nix-daemon.enable = true;
    tailscale.enable = true;
  };

  # Setup user, packages, programs
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

  # Turn off NIX_PATH warnings now that we're using flakes
  system.checks.verifyNixPath = false;

  # Load configuration that is shared across systems
  environment.systemPackages = import ../../modules/shared/system_packages.nix { inherit pkgs; };

  security.pam.enableSudoTouchIdAuth = true;

  system = {
    stateVersion = 4;

    defaults = {
      LaunchServices = {
        LSQuarantine = false;
      };

      NSGlobalDomain = {
        AppleShowAllExtensions = true;
        ApplePressAndHoldEnabled = false;

        # 120, 90, 60, 30, 12, 6, 2
        KeyRepeat = 2;

        # 120, 94, 68, 35, 25, 15
        InitialKeyRepeat = 15;

        "com.apple.mouse.tapBehavior" = 1;
        "com.apple.sound.beep.volume" = 0.0;
        "com.apple.sound.beep.feedback" = 0;

        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
        NSAutomaticWindowAnimationsEnabled = false;
        NSDocumentSaveNewDocumentsToCloud = false;
        NSNavPanelExpandedStateForSaveMode = true;
        PMPrintingExpandedStateForPrint = true;
      };

      dock = {
        launchanim = false;
        autohide = true;
        expose-animation-duration = 0.15;
        show-recents = false;
        showhidden = true;
        persistent-apps = [ ];
        mouse-over-hilite-stack = true;
        tilesize = 30;
        orientation = "bottom";
        wvous-bl-corner = 1;
        wvous-br-corner = 1;
        wvous-tl-corner = 1;
        wvous-tr-corner = 1;
      };

      screencapture =
        let
          inherit (config.sharedVariables) user;
        in
        {
          location = "/Users/${user}/Downloads/temp";
          type = "png";
          disable-shadow = true;
        };

      finder = {
        AppleShowAllFiles = true;
        CreateDesktop = false;
        FXDefaultSearchScope = "SCcf";
        FXEnableExtensionChangeWarning = false;
        FXPreferredViewStyle = "Nlsv";
        QuitMenuItem = true;
        ShowPathbar = true;
        ShowStatusBar = true;
        _FXShowPosixPathInTitle = false;
        _FXSortFoldersFirst = true;
      };

      trackpad = {
        TrackpadRightClick = true;
        TrackpadThreeFingerDrag = false;
        Clicking = true;
      };
    };

    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
      swapLeftCtrlAndFn = true;
      # Remap §± to ~
      userKeyMapping = [
        {
          HIDKeyboardModifierMappingDst = 30064771125;
          HIDKeyboardModifierMappingSrc = 30064771172;
        }
      ];
    };
  };
}
