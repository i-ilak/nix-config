{ pkgs
, inputs
, config
, lib
, ...
}:
let
  user = "utm";
  homeDir = "/home/${user}";
  sharedModules = import ../../modules/shared/home-manager.nix { inherit pkgs config lib user; };
in
{
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
