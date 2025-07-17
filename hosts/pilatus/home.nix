{ pkgs
, inputs
, ...
}:
{
  imports = [
    # inputs.catppuccin.homeModules.catppuccin
    ./additional_config_parameters.nix
    ../../modules/home-manager/i3.nix
    # ../../modules/home-manager/programs/git.nix
    ../../modules/home-manager/programs/rofi.nix
    ../../modules/home-manager/programs/fish.nix
    ../../modules/home-manager/programs/direnv.nix
    ../../modules/home-manager/programs/alacritty.nix
    ../../modules/home-manager/programs/fzf.nix
    ../../modules/home-manager/programs/i3_status_rust.nix
    ../../modules/home-manager/programs/polybar.nix
    ../../modules/home-manager/programs/ghostty.nix
  ];

  home = {
    enableNixpkgsReleaseCheck = false;
    packages = pkgs.callPackage ./packages.nix { inherit inputs; };
    file = import ./files.nix { };
    stateVersion = "25.05";
  };

  # catppuccin = {
  #   flavor = "mocha";
  #   enable = true;
  # };
}
