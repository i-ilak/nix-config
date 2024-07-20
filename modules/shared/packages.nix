{ pkgs, ... }:

with pkgs; [
    # General packages for development and system management
    alacritty
    bash-completion
    coreutils
    killall
    neofetch
    openssh
    wget
    zip
    neovim

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
    texlive.combined.scheme-full
    clang
    bear
    clang-tools
    cmake
    meson
    ctags
    gcc-arm-embedded

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
