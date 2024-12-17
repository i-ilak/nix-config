{ pkgs
, inputs
, config
, ...
}:
{
  imports = [
    ../../modules/shared/programs/git.nix
    ../../modules/shared/programs/zsh.nix
    ../../modules/shared/programs/direnv.nix
    ../../modules/shared/programs/alacritty.nix
  ];

  home = {
    username = config.sharedVariables.user;
    homeDirectory = config.sharedVariables.homeDir;
    packages = [
      inputs.nixvim.packages.${pkgs.system}.default
    ];
    file.".config/i3/i3.conf".source = ../../modules/dotfiles/linux/i3/config;
  };


  xsession.windowManager.i3 = {
    configFile = "${config.sharedVariables.homeDir}/i3/i3.conf";
  };

  programs = { home-manager.enable = true; };

  home.stateVersion = "24.11";
}
