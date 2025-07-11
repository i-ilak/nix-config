{ inputs
, pkgs
, config
, ...
}:
{
  imports =
    [
      inputs.disko.nixosModules.disko
      inputs.impermanence.nixosModules.impermanence
      ./disk-config.nix
      ./boot.nix
      ./sops.nix
      ./locale.nix
      ./audit.nix
      ./sudo.nix
      ./no-defaults.nix
      ./noexec.nix
      ./sshd.nix
      ./jellyfin.nix
      ./tailscale.nix
    ];

  environment.persistence."/persist" = {
    directories = [
      "/etc/nixos"
      "/passwords"
      "/var/lib"
      "/var/log"
      "/var/lib/sops-nix"
    ];
    files = [
      "/etc/machine-id"

      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
    ];
  };

  fileSystems."/persist".neededForBoot = true;

  fileSystems."/" = {
    device = "tmpfs";
    fsType = "tmpfs";
    options = [ "defaults" "size=2G" "mode=755" ];
  };

  networking = {
    hostName = "eiger";
    firewall.enable = true;
  };

  virtualisation.vmware.guest.enable = true;

  users = {
    groups.media = { };
    mutableUsers = false;
    users = {
      root.hashedPassword = "$y$j9T$dTeAq0ghLi2QWHogO1Jw10$UzHAEX.TWuyUBh7R1PR3NSBblesY2oF4E0JcsNuANX3";
      worker = {
        hashedPasswordFile = config.sops.secrets."user-worker-password".path;
        isNormalUser = true;
        extraGroups = [ "media" ];
      };
    };
  };

  nix.settings.allowed-users = [ "root" ];

  environment.systemPackages = with pkgs; [
    neovim
    rsync
    tree
    jellyfin
    jellyfin-web
    jellyfin-ffmpeg
  ];

  # DO NOT CHANGE, EVER.
  # Needs to be the version of the installer that was used to install the initial version of NixOS
  system.stateVersion = "25.05"; # Did you read the comment?
}

