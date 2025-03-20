{ pkgs
, inputs
, ...
}:
with pkgs;
[
  dockutil
  tailscale
  fd
  bat
  ripgrep
  inputs.nixvim.packages.${pkgs.system}.default

  # Fonts
  meslo-lgs-nf
]
