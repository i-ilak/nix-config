{ pkgs
, inputs
, lib
, config
, ...
}:
let
  inherit (inputs) nixgl;
  inherit (inputs) nixvim;
in
{
  imports = [
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
    ../../modules/home-manager/programs/ghostty.nix
  ];

  nixGL = {
    inherit (nixgl) packages;
    defaultWrapper = "nvidiaPrime";
    offloadWrapper = "mesa";
    installScripts = [ "mesa" "nvidiaPrime" ];
  };

  xsession = {
    enable = true;
  };

  home = {
    packages = import ./packages.nix { inherit pkgs nixvim config; };
    file = import ./files.nix { inherit pkgs nixvim config; };
    username = config.sharedVariables.user;
    homeDirectory = config.sharedVariables.homeDir;
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
    vscode = {
      enable = true;
      package = pkgs.vscode;
    };
    alacritty.package = config.lib.nixGL.wrap pkgs.alacritty;
  };

  home.stateVersion = "24.11";
}
