{ pkgs
, inputs
, ...
}:
with pkgs;
[
  dockutil
  tailscale
  inputs.nixvim.packages.${pkgs.system}.default

  # Fonts
  meslo-lgs-nf
]
