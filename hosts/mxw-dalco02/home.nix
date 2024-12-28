{ pkgs
, inputs
, lib
, config
, ...
}:
let
  inherit (inputs) nixgl;
  sharedFiles = import ../../modules/shared/files.nix {
    inherit config pkgs lib;
  };
in
{
  imports = [
    ../../modules/shared/programs/git.nix
    ../../modules/shared/programs/zsh.nix
    ../../modules/shared/programs/direnv.nix
    ../../modules/shared/programs/alacritty.nix
  ];

  nixGL = {
    inherit (nixgl) packages;
    defaultWrapper = "nvidiaPrime";
    offloadWrapper = "mesa";
    installScripts = [ "mesa" "nvidiaPrime" ];
  };

  home = {
    username = config.sharedVariables.user;
    homeDirectory = config.sharedVariables.homeDir;
    packages = with pkgs; [
      keepassxc
      firefox
      thunderbird
      rofi
      polybar

      # development
      uv
      ripgrep
      docker
      tree
      inputs.nixvim.packages.${pkgs.system}.default
      (config.lib.nixGL.wrap inputs.ghostty.packages.${pkgs.system}.default)

      #fonts
      meslo-lgs-nf
      udev-gothic-nf
      font-awesome
      noto-fonts
      noto-fonts-emoji
    ];
    file = lib.mkMerge [
      sharedFiles
    ];
  };

  catppuccin = {
    flavor = "mocha";
    enable = true; # Enables it for all supported tools
  };

  nixpkgs.config.allowUnfree = true;
  fonts.fontconfig.enable = true;

  programs = {
    home-manager.enable = true;
    alacritty.package = config.lib.nixGL.wrap pkgs.alacritty;
  };

  home.stateVersion = "24.11";
}
