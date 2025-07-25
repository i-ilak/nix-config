#!/bin/bash

temp=$(mktemp -d)

cleanup() {
    rm -rf "$temp"
}
trap cleanup EXIT

mkdir -p "$temp/etc/ssh"
# Ensure correct permissions on the source files, as you had it
sudo cp ~/.ssh/nixos_deploy "$temp/etc/ssh/ssh_host_ed25519_key"
sudo chmod 600 "$temp/etc/ssh/ssh_host_ed25519_key"
sudo cp ~/.ssh/nixos_deploy.pub "$temp/etc/ssh/ssh_host_ed25519_key.pub"
sudo chmod 644 "$temp/etc/ssh/ssh_host_ed25519_key.pub"
sudo chown -R iilak "$temp/etc/ssh/"

mkdir -p "$temp/persist/etc/ssh"
# Ensure correct permissions on the source files, as you had it
sudo cp ~/.ssh/nixos_deploy "$temp/persist/etc/ssh/ssh_host_ed25519_key"
sudo chmod 600 "$temp/persist/etc/ssh/ssh_host_ed25519_key"
sudo cp ~/.ssh/nixos_deploy.pub "$temp/persist/etc/ssh/ssh_host_ed25519_key.pub"
sudo chmod 644 "$temp/persist/etc/ssh/ssh_host_ed25519_key.pub"
sudo chown -R iilak "$temp/persist/etc/ssh/"


nix run github:nix-community/nixos-anywhere -- \
    --flake '.#nordwand' \
    --build-on local \
    --extra-files "$temp" \
    --disk-encryption-keys /tmp/secret.key /tmp/secret.key \
    --no-disko-deps \
    --option max-jobs 1 \
    --option cores 1 \
    --target-host nixos@$1

# Cleanup will happen automatically due to trap EXIT
