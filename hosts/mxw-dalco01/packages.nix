{ inputs
, pkgs
, nixvim
, config
, ...
}:
let
  sharedPackages = import ../../modules/home-manager/shared_packages.nix { inherit pkgs nixvim; };

  guiApplications = with pkgs; [
    keepassxc
    thunderbird
    dmenu
    mupdf
    p7zip
    colordiff
    nitrogen
    jetbrains.clion
  ];

  developmentPackages = with pkgs; [
    awscli2
    ranger
    ccache
    doxygen
    # Needed for fish plugin
    grc
  ];
  fonts = with pkgs; [
    meslo-lgs-nf
    udev-gothic-nf
    font-awesome
    noto-fonts
    noto-fonts-emoji
  ];

  # Currently installed manually since I need Bitwarden 2025.5.0 and unstable has only 2025.4.2
  # unstablePackages = with inputs.nixpkgs-unstable.legacyPackages."x86_64-linux"; [ bitwarden-desktop ];

  packages = guiApplications
    ++ developmentPackages
    ++ fonts
    # ++ unstablePackages
    ++ sharedPackages;
in
packages
