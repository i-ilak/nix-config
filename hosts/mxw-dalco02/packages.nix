{ pkgs
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
    (config.lib.nixGL.wrap dolphin)
  ];

  developmentPackages = with pkgs; [
    awscli2
    ranger
    ccache
    doxygen
    grc # Needed for fish plugin
  ];
  fonts = with pkgs; [
    meslo-lgs-nf
    udev-gothic-nf
    font-awesome
    noto-fonts
    noto-fonts-emoji
  ];

  packages = guiApplications
    ++ developmentPackages
    ++ fonts
    ++ sharedPackages;
in
packages
