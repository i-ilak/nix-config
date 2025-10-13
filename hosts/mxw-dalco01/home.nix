{
  pkgs,
  inputs,
  config,
  ...
}:
let
  inherit (inputs) nixgl;
  inherit (inputs) nixvim;
  inherit (config.sharedVariables) homeDir;
  secretspath = builtins.toString inputs.nix-secrets;
in
{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
    ../../modules/home-manager/i3.nix
    ../../modules/home-manager/programs/git.nix
    # ../../modules/home-manager/programs/zsh.nix
    ../../modules/home-manager/programs/rofi.nix
    ../../modules/home-manager/programs/fish.nix
    ../../modules/home-manager/programs/direnv.nix
    ../../modules/home-manager/programs/alacritty.nix
    ../../modules/home-manager/programs/fzf.nix
    ../../modules/home-manager/programs/i3_status_rust.nix
    ../../modules/home-manager/programs/polybar.nix
    ../../modules/home-manager/programs/dunst.nix
    ../../modules/home-manager/programs/ghostty.nix
    ../../modules/home-manager/programs/helix
  ];

  nixGL = {
    inherit (nixgl) packages;
    defaultWrapper = "mesa";
    offloadWrapper = "nvidiaPrime";
    installScripts = [
      "mesa"
      "nvidiaPrime"
    ];
  };

  xsession = {
    enable = true;
  };

  home = {
    packages = import ./packages.nix {
      inherit
        inputs
        pkgs
        nixvim
        config
        ;
    };
    file = import ./files.nix { inherit pkgs nixvim config; };
    username = config.sharedVariables.user;
    homeDirectory = config.sharedVariables.homeDir;
  };

  sops = {
    defaultSopsFile = "${secretspath}/secrets/shared.yaml";
    age = {
      keyFile = "${homeDir}/.config/sops/age/keys.txt";
    };
    secrets = {
      "ssh_git_signing_key/work" = { };
      ssh_config = {
        sopsFile = "${secretspath}/secrets/mxw-dalco01/ssh_config";
        path = "${config.sharedVariables.homeDir}/.ssh/config";
        mode = "0600";
        format = "binary";
      };
    };

  };

  catppuccin = {
    flavor = "mocha";
    enable = true; # Enables it for all supported tools
    rofi.enable = false;
  };

  nixpkgs.config.allowUnfree = true;
  fonts.fontconfig.enable = true;

  programs = {
    home-manager.enable = true;
    alacritty.package = config.lib.nixGL.wrap pkgs.alacritty;
  };

  home.stateVersion = "24.11";
}
