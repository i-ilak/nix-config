#!/bin/bash

temp=$(mktemp -d)

cleanup() {
    rm -rf "$temp"
}
trap cleanup EXIT

mkdir -p "$temp/etc/ssh"
# Ensure correct permissions on the source files, as you had it
sudo cp /etc/ssh/ssh_host_ed25519_key "$temp/etc/ssh/ssh_host_ed25519_key"
sudo chmod 600 "$temp/etc/ssh/ssh_host_ed25519_key"
sudo cp /etc/ssh/ssh_host_ed25519_key.pub "$temp/etc/ssh/ssh_host_ed25519_key.pub"
sudo chmod 644 "$temp/etc/ssh/ssh_host_ed25519_key.pub"
sudo chown -R iilak "$temp/etc/ssh/"

mkdir -p "$temp/persist/etc/ssh"
# Ensure correct permissions on the source files, as you had it
sudo cp /etc/ssh/ssh_host_ed25519_key "$temp/persist/etc/ssh/ssh_host_ed25519_key"
sudo chmod 600 "$temp/persist/etc/ssh/ssh_host_ed25519_key"
sudo cp /etc/ssh/ssh_host_ed25519_key.pub "$temp/persist/etc/ssh/ssh_host_ed25519_key.pub"
sudo chmod 644 "$temp/persist/etc/ssh/ssh_host_ed25519_key.pub"
sudo chown -R iilak "$temp/persist/etc/ssh/"


nix run github:nix-community/nixos-anywhere -- \
    --flake '.#eiger' \
    --build-on remote \
    --extra-files "$temp" \
    --disk-encryption-keys /tmp/secret.key /tmp/secret.key \
    --target-host nixos@$1

# Cleanup will happen automatically due to trap EXIT
