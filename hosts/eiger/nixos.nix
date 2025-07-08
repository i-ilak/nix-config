{ inputs
, ...
}:
inputs.nixpkgs.lib.nixosSystem {
  # TODO: Change back, real machine is x86_64-linux
  # system = "x86_64-linux";
  system = "aarch64-linux";
  specialArgs = { inherit inputs; };
  modules = [
    inputs.sops-nix.nixosModules.sops
    ./default.nix
  ];
}

