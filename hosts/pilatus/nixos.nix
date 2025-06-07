{ inputs
, ...
}:
inputs.nixpkgs.lib.nixosSystem {
  system = "aarch64-linux";
  specialArgs = { inherit inputs; };
  modules = [
    inputs.home-manager.nixosModules.home-manager
    ./default.nix
  ];
}

