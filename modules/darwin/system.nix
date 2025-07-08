{ config
, ...
}:
let
  inherit (config.sharedVariables) user;
in
{
  stateVersion = 4;
  checks.verifyNixPath = false;

  primaryUser = "iilak";

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
    userKeyMapping = [
      # Remap §± to ~
      {
        HIDKeyboardModifierMappingDst = 30064771125;
        HIDKeyboardModifierMappingSrc = 30064771172;
      }
      # # Remap `Ctrl+Backspace` to `Forward Delete`
      # {
      #
      #   HIDKeyboardModifierMappingDst = 30064771306;
      #   HIDKeyboardModifierMappingSrc = 30064771148;
      # }
    ];
  };
}
