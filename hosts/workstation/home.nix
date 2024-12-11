{ pkgs
, inputs
, config
, lib
, ...
}:
let
  user = "iilak";
  homeDir = "/home/${user}";
  sharedModules = import ../../modules/shared/home-manager.nix { inherit pkgs config lib user; };
in
{
  import = [
    ../../modules/shared/programs/git.nix
    ../../modules/shared/programs/zsh.nix
    ../../modules/shared/programs/direnv.nix
    ../../modules/shared/programs/alacritty.nix
  ];

  home = {
    username = user;
    homeDirectory = homeDir;
    packages = [
      inputs.nixvim.packages.${pkgs.system}.default
    ];
  };

  programs = {
    home-manager.enable = true;
  } // sharedModules;

  home.stateVersion = "24.11";
}
