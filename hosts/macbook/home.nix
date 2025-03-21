{ pkgs
, inputs
, ...
}:
{
  imports = [
    inputs.catppuccin.homeManagerModules.catppuccin
    ./additional_config_parameters.nix
    ../../modules/home-manager/programs/git.nix
    ../../modules/home-manager/programs/zsh.nix
    ../../modules/home-manager/programs/fzf.nix
    ../../modules/home-manager/programs/fish.nix
    ../../modules/home-manager/programs/direnv.nix
    ../../modules/home-manager/programs/alacritty.nix
  ];

  home = {
    enableNixpkgsReleaseCheck = false;
    packages = pkgs.callPackage ./packages.nix { inherit inputs; };
    file = import ./files.nix { };
    stateVersion = "24.05";
  };

  catppuccin = {
    flavor = "mocha";
    enable = true; # Enables it for all supported tools
  };
}
