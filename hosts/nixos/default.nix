{ config, inputs, lib, pkgs, ... }:

let 
  user = "iilak";
  keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO2CVn3MpTPf9D+Ljpst32oXI8OOcO2A0b3Fulobv9lt" ];
in
{
  imports = [
    ../../modules/shared
    ../../modules/shared/cachix
  ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    initrd.luks.devices.luksroot = {
      device = "/dev/disk/by-uuid/3619778a-c8b1-475b-a785-34c0761c65bf";
      preLVM = true;
      allowDiscards = true;
    };
  };  

  networking = {
    networkmanager.enable = true;  # Easiest to use and most distros use this by default.
    hostName = "nix";
    firewall.allowedTCPPorts = [ 22022 ];
  };

  time.timeZone = "Europe/Amsterdam";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Turn on flag for proprietary software
  nix = {
    nixPath = [ "nixos-config=/home/${user}/.local/share/src/nixos-config:/etc/nixos" ];
    settings.allowed-users = [ "${user}" ];
    package = pkgs.nix;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
   };

  # Manages keys and such
  programs = {
    gnupg.agent.enable = true;

    # Needed for anything GTK related
    dconf.enable = true;

    # My shell
    zsh.enable = true;
  };

  services = {
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
    #picom = {
    #  enable = true;
    #  settings = {
    #    animations = true;
    #    animation-stiffness = 300.0;
    #    animation-dampening = 35.0;
    #    animation-clamping = false;
    #    animation-mass = 1;
    #    animation-for-workspace-switch-in = "auto";
    #    animation-for-workspace-switch-out = "auto";
    #    animation-for-open-window = "slide-down";
    #    animation-for-menu-window = "none";
    #    animation-for-transient-window = "slide-down";
    #    corner-radius = 12;
    #    rounded-corners-exclude = [
    #      "class_i = 'polybar'"
    #      "class_g = 'i3lock'"
    #    ];
    #    round-borders = 3;
    #    round-borders-exclude = [];
    #    round-borders-rule = [];
    #    shadow = true;
    #    shadow-radius = 8;
    #    shadow-opacity = 0.4;
    #    shadow-offset-x = -8;
    #    shadow-offset-y = -8;
    #    fading = false;
    #    inactive-opacity = 0.8;
    #    frame-opacity = 0.7;
    #    inactive-opacity-override = false;
    #    active-opacity = 1.0;
    #    focus-exclude = [
    #    ];
    #
    #    opacity-rule = [
    #      "100:class_g = 'i3lock'"
    #      "60:class_g = 'Dunst'"
    #      "100:class_g = 'Alacritty' && focused"
    #      "90:class_g = 'Alacritty' && !focused"
    #    ];
    #
    #    blur-kern = "3x3box";
    #    blur = {
    #      method = "kernel";
    #      strength = 8;
    #      background = false;
    #      background-frame = false;
    #      background-fixed = false;
    #      kern = "3x3box";
    #    };
    #
    #    shadow-exclude = [
    #      "class_g = 'Dunst'"
    #    ];
    #
    #    blur-background-exclude = [
    #      "class_g = 'Dunst'"
    #    ];
    #
    #    backend = "glx";
    #    vsync = false;
    #    mark-wmwin-focused = true;
    #    mark-ovredir-focused = true;
    #    detect-rounded-corners = true;
    #    detect-client-opacity = false;
    #    detect-transient = true;
    #    detect-client-leader = true;
    #    use-damage = true;
    #    log-level = "info";
    #
    #    wintypes = {
    #      normal = { fade = true; shadow = false; };
    #      tooltip = { fade = true; shadow = false; opacity = 0.75; focus = true; full-shadow = false; };
    #      dock = { shadow = false; };
    #      dnd = { shadow = false; };
    #      popup_menu = { opacity = 1.0; };
    #      dropdown_menu = { opacity = 1.0; };
    #    };
    #  };
    #};

    # Let's be able to SSH into this machine
    openssh = {
      enable = true;
      ports = [ 22022 ];
      settings = {
        X11Forwarding = false;
        PermitRootLogin = "no";
      };
    };

    gvfs.enable = true; # Mount, trash, and other functionalities
    tumbler.enable = true; # Thumbnail support for images
  };

  # Enable sound
  sound.enable = true;
  hardware = {
    pulseaudio.enable = true;

    # Video support
    opengl = {
      enable = true;
      driSupport32Bit = true;
      driSupport = true;
    };

    #nvidia.modesetting.enable = true;

    # Crypto wallet support
    ledger.enable = true;
  };

  # Add docker daemon
  virtualisation = {
    docker = {
      enable = true;
      logDriver = "json-file";
    };
  };

  # It's me, it's you, it's everyone
  users.users = {
    ${user} = {
      isNormalUser = true;
      extraGroups = [
        "wheel" # Enable ‘sudo’ for the user.
        "docker"
      ];
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = keys;
    };

    root = {
      openssh.authorizedKeys.keys = keys;
    };
  };

  # Don't require password for users in `wheel` group for these commands
  security.sudo = {
    enable = true;
    extraRules = [{
      commands = [
       {
         command = "${pkgs.systemd}/bin/reboot";
         options = [ "NOPASSWD" ];
        }
      ];
      groups = [ "wheel" ];
    }];
  };

  fonts.packages = with pkgs; [
    meslo-lgs-nf
    dejavu_fonts
    emacs-all-the-icons-fonts
    feather-font # from overlay
    jetbrains-mono
    font-awesome
    noto-fonts
    noto-fonts-emoji
  ];

  environment.systemPackages = with pkgs; [
    gitAndTools.gitFull
    linuxPackages.v4l2loopback
    v4l-utils
    inetutils
  ];

  system.stateVersion = "24.05"; 
}
