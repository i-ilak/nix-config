{ pkgs, ... }:

with pkgs; [
  # General packages for development and system management
  alacritty
  bash-completion
  coreutils
  gcc
  killall
  neofetch
  openssh
  wget
  zip

  # Encryption and security tools
  gnupg
  libfido2

  # Cloud-related tools and SDKs
  docker
  docker-compose

  # Media-related packages
  imagemagick
  ffmpeg
  font-awesome
  glow
  hack-font
  jpegoptim
  meslo-lgs-nf
  noto-fonts
  noto-fonts-emoji
  pngquant

  # Node.js development tools
  nodePackages.npm

  # Source code management, Git, GitHub tools
  gh

  # Text and terminal utilities
  htop
  jq
  ripgrep
  tree
  tmux
  unzip
  zsh-powerlevel10k

  # Python packages
  black
  python310
  python310Packages.virtualenv
]
