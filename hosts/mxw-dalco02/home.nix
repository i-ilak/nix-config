{ pkgs
, inputs
, config
, ...
}:
let
  inherit (inputs) nixgl;
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
    defaultWrapper = "mesa";
    offloadWrapper = "nvidiaPrime";
    installScripts = [ "mesa" "nvidiaPrime" ];
  };

  home = {
    username = config.sharedVariables.user;
    homeDirectory = config.sharedVariables.homeDir;
    packages = with pkgs; [
      inputs.nixvim.packages.${pkgs.system}.default
      keepassxc
      uv
      ripgrep
      meslo-lgs-nf
      font-awesome
      noto-fonts
      noto-fonts-emoji
    ];
    file.".config/i3/i3.conf".source = ../../modules/dotfiles/linux/i3/config;
  };


  xsession.windowManager.i3 = {
    configFile = "${config.sharedVariables.homeDir}/i3/i3.conf";
  };

  fonts.fontconfig.enable = true;

  programs = {
    home-manager.enable = true;
    alacritty.package = config.lib.nixGL.wrap pkgs.alacritty;
  };

  home.stateVersion = "24.11";
}
