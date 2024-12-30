{ config
, pkgs
, lib
, inputs
, ...
}:
let
  inherit (config.sharedVariables) user;
  sharedFiles = import ../../modules/shared/files.nix {
    inherit config pkgs lib;
  };
  additionalFiles = import ../../modules/darwin/files.nix { inherit user config pkgs; };
in
{
  imports = [
    inputs.catppuccin.homeManagerModules.catppuccin
    ./additional_config_parameters.nix
    ../../modules/home-manager/programs/git.nix
    ../../modules/home-manager/programs/zsh.nix
    ../../modules/home-manager/programs/direnv.nix
    ../../modules/home-manager/programs/alacritty.nix
  ];

  home = {
    enableNixpkgsReleaseCheck = false;
    packages = pkgs.callPackage ./packages.nix { inherit inputs; };
    file = lib.mkMerge [
      sharedFiles
      additionalFiles
    ];

    stateVersion = "24.05";
  };

  catppuccin = {
    flavor = "mocha";
    enable = true; # Enables it for all supported tools
  };
}
