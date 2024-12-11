{ pkgs
, inputs
, config
, lib
, ...
}:
let
  user = "iilak";
  homeDir = "/home/${user}";
  sharedModules = { }
    // (import ../../modules/shared/programs/git.nix { inherit config lib pkgs user; })
    // (import ../../modules/shared/programs/zsh.nix { inherit config lib pkgs user; })
    // (import ../../modules/shared/programs/direnv.nix { inherit config lib pkgs user; })
    // (import ../../modules/shared/programs/alacritty.nix { inherit config lib pkgs user; });
in
{
  home = {
    username = user;
    homeDirectory = homeDir;
    packages = [
      inputs.nixvim.packages.${pkgs.system}.default
    ];
  };

  programs = { home-manager.enable = true; } // sharedModules;

  home.stateVersion = "24.11";
}
