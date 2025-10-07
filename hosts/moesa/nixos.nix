{
  inputs,
  ...
}:
inputs.nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = { inherit inputs; };
  modules = [
    inputs.sops-nix.nixosModules.sops
    ./default.nix
  ];
}
