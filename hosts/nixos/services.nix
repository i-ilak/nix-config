{ pkgs, ... }: {
  services = {
    # Let's be able to SSH into this machine
    openssh = {
      enable = true;
      ports = [ 22022 ];
      settings = {
        X11Forwarding = false;
        PermitRootLogin = "no";
      };
    };

    # udiskie.enable = true; # Auto-mount removable devices
    gvfs.enable = true; # Mount, trash, and other functionalities
    tumbler.enable = true; # Thumbnail support for images

    screen-locker = {
      enable = true;
      inactiveInterval = 10;
      # lockCmd = "${pkgs.i3lock-fancy-rapid}/bin/i3lock-fancy-rapid 10 15";
      lockCmd = "${pkgs.swaylock}/bin/swaylock --color 0000ff";
    };

    dunst = {
      enable = true;
      settings = {
        global = {
          monitor = 0;
          follow = "mouse";
          border = 0;
          height = 400;
          width = 320;
          offset = "33x65";
          indicate_hidden = "yes";
          shrink = "no";
          separator_height = 0;
          padding = 32;
          horizontal_padding = 32;
          frame_width = 0;
          sort = "no";
          idle_threshold = 120;
          font = "Noto Sans";
          line_height = 4;
          markup = "full";
          format = "<b>%s</b>\n%b";
          alignment = "left";
          transparency = 10;
          show_age_threshold = 60;
          word_wrap = "yes";
          ignore_newline = "no";
          stack_duplicates = false;
          hide_duplicate_count = "yes";
          show_indicators = "no";
          icon_position = "left";
          icon_theme = "Adwaita-dark";
          sticky_history = "yes";
          history_length = 20;
          history = "ctrl+grave";
          browser = "google-chrome-stable";
          always_run_script = true;
          title = "Dunst";
          class = "Dunst";
          max_icon_size = 64;
        };
      };
    };

    #xserver = {
    #  enable = true;
    #
    #  videoDrivers = [ "nvidia" ];
    #
    #  # This helps fix tearing of windows for Nvidia cards
    #  screenSection = ''
    #    Option       "metamodes" "nvidia-auto-select +0+0 {ForceFullCompositionPipeline=On}"
    #    Option       "AllowIndirectGLXProtocol" "off"
    #    Option       "TripleBuffer" "on"
    #  '';
    #
    #  # LightDM Display Manager
    #  displayManager.defaultSession = "none+bspwm";
    #  displayManager.lightdm = {
    #    enable = true;
    #    greeters.slick.enable = true;
    #    background = ../../modules/nixos/config/login-wallpaper.png;
    #  };
    #
    #  # Tiling window manager
    #  windowManager.bspwm = {
    #    enable = true;
    #  };
    #
    #  # Better support for general peripherals
    #  libinput.enable = true;
    #
    #  # Turn Caps Lock into Ctrl
    #  xkb = {
    #    layout = "us";
    #    options = "ctrl:nocaps";
    #  };
    #};

    # Picom, my window compositor with fancy effects
    #
    # Notes on writing exclude rules:
    #
    #   class_g looks up index 1 in WM_CLASS value for an application
    #   class_i looks up index 0
    #
    #   To find the value for a specific application, use `xprop` at the
    #   terminal and then click on a window of the application in question
    #
    picom = {
      enable = true;
      settings = {
        animations = true;
        animation-stiffness = 300.0;
        animation-dampening = 35.0;
        animation-clamping = false;
        animation-mass = 1;
        animation-for-workspace-switch-in = "auto";
        animation-for-workspace-switch-out = "auto";
        animation-for-open-window = "slide-down";
        animation-for-menu-window = "none";
        animation-for-transient-window = "slide-down";
        corner-radius = 12;
        rounded-corners-exclude = [
          "class_i = 'polybar'"
          "class_g = 'i3lock'"
        ];
        round-borders = 3;
        round-borders-exclude = [ ];
        round-borders-rule = [ ];
        shadow = true;
        shadow-radius = 8;
        shadow-opacity = 0.4;
        shadow-offset-x = -8;
        shadow-offset-y = -8;
        fading = false;
        inactive-opacity = 0.8;
        frame-opacity = 0.7;
        inactive-opacity-override = false;
        active-opacity = 1.0;
        focus-exclude = [
        ];

        opacity-rule = [
          "100:class_g = 'i3lock'"
          "60:class_g = 'Dunst'"
          "100:class_g = 'Alacritty' && focused"
          "90:class_g = 'Alacritty' && !focused"
        ];

        blur-kern = "3x3box";
        blur = {
          method = "kernel";
          strength = 8;
          background = false;
          background-frame = false;
          background-fixed = false;
          kern = "3x3box";
        };

        shadow-exclude = [
          "class_g = 'Dunst'"
        ];

        blur-background-exclude = [
          "class_g = 'Dunst'"
        ];

        backend = "glx";
        vsync = false;
        mark-wmwin-focused = true;
        mark-ovredir-focused = true;
        detect-rounded-corners = true;
        detect-client-opacity = false;
        detect-transient = true;
        detect-client-leader = true;
        use-damage = true;
        log-level = "info";

        wintypes = {
          normal = {
            fade = true;
            shadow = false;
          };
          tooltip = {
            fade = true;
            shadow = false;
            opacity = 0.75;
            focus = true;
            full-shadow = false;
          };
          dock = { shadow = false; };
          dnd = { shadow = false; };
          popup_menu = { opacity = 1.0; };
          dropdown_menu = { opacity = 1.0; };
        };
      };
    };
  };
}
