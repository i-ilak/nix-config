{ nixpkgs
, inputs
}:
inputs.home-manager.lib.homeManagerConfiguration
{
  pkgs = nixpkgs.legacyPackages.x86_64-linux;
  modules = [
    inputs.catppuccin.homeModules.catppuccin
    ./additional_config_parameters.nix
    ./home.nix
  ];
  extraSpecialArgs =
    { inherit inputs; }
    // {
      isNixOS = false;
      impurePaths = {
        workingDir = "/home/${inputs.config.sharedVariables.user}/.config/nix";
      };
    };
}
