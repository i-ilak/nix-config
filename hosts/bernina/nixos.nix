{
  inputs,
  ...
}:
inputs.nixpkgs.lib.nixosSystem {
  system = "aarch64-linux";
  specialArgs = { inherit inputs; };
  modules = [
    inputs.sops-nix.nixosModules.sops
    ./default.nix

    # "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
    #
    # {
    #   sdImage = {
    #     compressImage = true;
    #     expandOnBoot = true;
    #   };
    # }
  ];
}
