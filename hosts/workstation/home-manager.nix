{ nixpkgs
, inputs
}:
inputs.home-manager.lib.homeManagerConfiguration
{
  pkgs = nixpkgs.legacyPackages.aarch64-linux;
  modules = [
    ./home.nix
    # ./modules/shared/home-manager.nix
  ];
  extraSpecialArgs =
    { inherit inputs; }
    // {
      isNixOS = false;
      impurePaths = {
        workingDir = "/home/iilak/.config/nix";
      };
    };
}
