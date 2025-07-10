#!/bin/bash

temp=$(mktemp -d)

cleanup() {
   rm -rf "$temp"
}
trap cleanup EXIT

mkdir -p "$temp/etc/ssh"
chmod 755 "$temp/etc/ssh"

sudo cp /etc/ssh/ssh_host_ed25519_key "$temp/etc/ssh/ssh_host_ed25519_key"
sudo chown iilak "$temp/etc/ssh/ssh_host_ed25519_key"
chmod 600 "$temp/etc/ssh/ssh_host_ed25519_key"

nix run github:nix-community/nixos-anywhere --              \
   --flake '.#eiger'                                     \
   --build-on remote                                       \
   --extra-files "$temp"                                   \
   --disk-encryption-keys /tmp/secret.key /tmp/secret.key  \
   --target-host nixos@$1
