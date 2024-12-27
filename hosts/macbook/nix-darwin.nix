{ inputs
,
}:
inputs.darwin.lib.darwinSystem {
  system = "aarch64-darwin";
  specialArgs = { inherit inputs; };
  modules = [
    inputs.home-manager.darwinModules.home-manager
    inputs.nix-homebrew.darwinModules.nix-homebrew
    {
      nix-homebrew = {
        enable = true;
        user = "iilak";
        taps = {
          "homebrew/homebrew-core" = inputs.homebrew-core;
          "homebrew/homebrew-cask" = inputs.homebrew-cask;
          "homebrew/homebrew-bundle" = inputs.homebrew-bundle;
        };
        mutableTaps = false;
        autoMigrate = true;
      };
    }
    ./macbook.nix
  ];
}

