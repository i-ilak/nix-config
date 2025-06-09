{ pkgs
, inputs
, ...
}:
let
  inherit (inputs) nixvim;
  sharedPackages = import ../../modules/home-manager/shared_packages.nix { inherit pkgs nixvim; };

  packages = with pkgs;
    [
      age # Needed for sops-nix to genereate initial key
      dockutil
      tailscale
      # Fonts
      meslo-lgs-nf
    ] ++
    sharedPackages;
in
packages
