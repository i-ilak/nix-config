{
  inputs,
  ...
}:
inputs.nixpkgs.lib.nixosSystem {
  system = "aarch64-linux";
  specialArgs = { inherit inputs; };
  modules = [
    inputs.sops-nix.nixosModules.sops
    inputs.authentik-nix.nixosModules.default
    ./default.nix
  ];
}
