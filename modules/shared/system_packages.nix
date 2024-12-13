{ pkgs
, ...
}:
with pkgs; [
  # General packages for development and system management
  bash-completion
  coreutils
  killall
  openssh
  wget
  zip
  colordiff

  # Encryption and security tools
  gnupg
  libfido2
  libiconv

  # Media-related packages
  font-awesome
  meslo-lgs-nf

  # Source code management, Git, GitHub tools
  gh

  # Text and terminal utilities
  htop
  jq
  ripgrep
  tree
  unzip
  zsh-powerlevel10k

  # Python packages
  black
  python311
  python311Packages.virtualenv
]
