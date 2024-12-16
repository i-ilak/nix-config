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
  };

  programs = { home-manager.enable = true; };

  home.stateVersion = "24.11";
}
