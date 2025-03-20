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
      "${xdg_configHome}/ccache/ccache.conf".source = ../../dotfiles/linux/ccache/ccache.conf;
      "${xdg_configHome}/systemd/user/dropbox.service".source = ../../dotfiles/linux/systemd/dropbox.service;
    };
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
    username = config.sharedVariables.user;
    homeDirectory = config.sharedVariables.homeDir;
    packages = with pkgs; [
      keepassxc
      # firefox
      thunderbird
      dmenu
      mupdf
      p7zip
      colordiff
      nitrogen
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
      grc # Needed for fish plugin
      fd
      libz # clangd does not bring it
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
