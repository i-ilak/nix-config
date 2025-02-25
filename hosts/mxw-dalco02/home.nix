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
  home = builtins.getEnv "HOME";
  xdg_configHome = "${home}/.config";

  files =
    {
      "${xdg_configHome}/i3/config".source = ../../dotfiles/linux/i3/config;
      "${xdg_configHome}/ccache/ccache.conf".source = ../../dotfiles/linux/ccache/ccache.conf;
      "${xdg_configHome}/systemd/user/dropbox.service".source = ../../dotfiles/linux/systemd/dropbox.service;
    };
in
{
  imports = [
    ../../modules/home-manager/programs/git.nix
    ../../modules/home-manager/programs/zsh.nix
    ../../modules/home-manager/programs/direnv.nix
    ../../modules/home-manager/programs/alacritty.nix
    ../../modules/home-manager/programs/fzf.nix
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
      # firefox
      thunderbird
      rofi
      polybar
      mupdf
      (config.lib.nixGL.wrap dolphin)


      # development
      uv
      ripgrep
      docker
      tree
      awscli2
      ranger
      ccache
      doxygen
      inputs.nixvim.packages.${pkgs.system}.default
      # (config.lib.nixGL.wrap inputs.ghostty.packages.${pkgs.system}.default)

      #fonts
      meslo-lgs-nf
      udev-gothic-nf
      font-awesome
      noto-fonts
      noto-fonts-emoji
    ];
    file = lib.mkMerge [
      sharedFiles
      files
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
    vscode = {
      enable = true;
      package = pkgs.vscode;
    };
    # alacritty.package = config.lib.nixGL.wrap pkgs.alacritty;
  };

  home.stateVersion = "24.11";
}
