{
  inputs,
  pkgs,
  config,
  lib,
  ...
}:
let
  inherit (config.sharedVariables) user;
  systemPackages = import ../../modules/shared/system_packages.nix { inherit pkgs; };
in
{
  imports = [
    inputs.disko.nixosModules.disko
    inputs.sops-nix.nixosModules.sops
    ./disk-config.nix
    ./additional_config_parameters.nix
    ../../modules/shared
    ../../modules/shared/cachix
    ../../modules/nixos/locale.nix
    ./boot.nix
    ./networking.nix
    ./services.nix
    ./fonts.nix
    ./security.nix
  ];

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

  programs = {
    fish.enable = true;
    firefox.enable = true;
  };

  sops =
    let
      secretspath = builtins.toString inputs.nix-secrets;
    in
    {
      defaultSopsFile = "${secretspath}/secrets/albula.yaml";
      secrets = {
        "user/dev/password" = { };
        "ssh_git_signing_key/public" = {
          sopsFile = "${secretspath}/secrets/shared.yaml";
          format = "yaml";
        };
      };
      age = {
        sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      };
    };

  users = {
    mutableUsers = false;
    users = {
      ${user} = {
        isNormalUser = true;
        extraGroups = [
          "wheel"
        ];
        shell = pkgs.fish;
        hashedPasswordFile = config.sops.secrets."user-dev-password".path;
      };
    };
  };

  hardware.graphics.enable = true;
  virtualisation.vmware.guest.enable = true;

  environment.systemPackages =
    with pkgs;
    [
      gitAndTools.gitFull
      linuxPackages.v4l2loopback
      v4l-utils
      inetutils
      vim
    ]
    ++ systemPackages;

  nix = {
    nixPath = [ "nixos-config=/home/${user}/.local/share/src/nixos-config:/etc/nixos" ];
    settings.allowed-users = [ "${user}" ];
    package = pkgs.nix;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # Do not change this, ever
  system.stateVersion = "25.05";
}
