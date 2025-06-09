# Setup

1. Clone the repository like this
    ```bash
    git clone --branch X http://github.com/i-ilak/nix-config.git /tmp/nixos
    ```
1. Create a file that stores the password for the disk encryption
    ```bash
    echo "MY_PASSWORD" > /tmp/secret.key
    ```
1. Run `disko` to format the disks
    ```bash
    nix --experimental-features "nix-command flakes" github:nix-community/disko -- --mode /tmp/nixos/hosts/pilatus/disk-config.nix
    ```
1. Move all the files to the correct location
    ```bash
    mkdir -p /mnt/etc
    mv /tmp/nixos /mnt/etc/
    ```
1. Install `NixOS`
    ```bash
    cd /mnt/etc/nixos
    nixos-install --flake .#pilatus
    ```
