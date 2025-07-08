# Setup

1. Create a file that stores the password for the disk encryption
   ```bash
   echo "LUKS_PASSWORD" > /tmp/secret.key
   ```
1. Run `nixos-anywhere` to deploy the flake to the installer

   ```bash
   temp=$(mktemp -d)

   cleanup() {
       rm -rf "$temp"
   }
   trap cleanup EXIT

   mkdir "$temp/etc/ssh"
   chmod 755 "$temp/etc/ssh"

   cp ~/.ssh/id_ed25519 "$temp/etc/ssh/ssh_host_ed25519_key"
   chmod 600 "$temp/etc/ssh/ssh_host_ed25519_key"

   nix run github:nix-community/nixos-anywhere --              \
       --flake '.#pilatus'                                     \
       --build-on-remote                                       \
       --build-on remote                                       \
       --extra-files "$temp"                                   \
       --disk-encryption-keys /tmp/secret.key /tmp/secret.key  \
       --target-host NIXOS_INSTALLER_IP
   ```
