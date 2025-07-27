{
  pkgs,
  inputs,
  ...
}:
let
  inherit (inputs) nixvim;
  sharedPackages = import ../../modules/home-manager/shared_packages.nix { inherit pkgs nixvim; };

  packages =
    with pkgs;
    [
      tailscale
      qbittorrent
      # Fonts
      meslo-lgs-nf
    ]
    ++ sharedPackages;
in
packages
