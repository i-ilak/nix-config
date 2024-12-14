{ inputs
, pkgs
, config
, lib
, ...
}:
let
  user = "test_user";
  hostname = "test";
  shared-files = import ../../modules/shared/files.nix { inherit config pkgs lib; };
  keys = [ "" ];
in
{
  imports = [
    inputs.disko.nixosModules.disko
    ./disk-config.nix
    # ./services.nix
    ../../modules/shared
    ../../modules/shared/cachix
  ];

  # Screen lock

  # programs =
  #   shared-programs
  #   // { gpg.enable = true; }
  #   // import "${toString ./.}/programs/waybar.nix";

  # This installs my GPG signing keys for Github
  #systemd.user.services.gpg-import-keys = {
  #  Unit = {
  #    Description = "Import gpg keys";
  #    After = [ "gpg-agent.socket" ];
  #  };
  #
  #  Service = {
  #    Type = "oneshot";
  #    ExecStart = toString (pkgs.writeScript "gpg-import-keys" ''
  #      #! ${pkgs.runtimeShell} -el
  #      ${lib.optionalString (gpgKeys!= []) ''
  #      ${pkgs.gnupg}/bin/gpg --import ${lib.concatStringsSep " " gpgKeys}
  #      ''}
  #    '');
  #  };
  #
  #  Install = { WantedBy = [ "default.target" ]; };
  #};

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

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

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
    dconf.enable = true;
    zsh.enable = true;
    hyprland = {
      enable = true;
      xwayland.enable = true;
    };
  };

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  hardware = {
    graphics = {
      enable = true;
    };

    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
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
    bluez
  ];

  system.stateVersion = "24.05";
}
