# Setup

1. Create a file that stores the password for the disk encryption
   ```bash
   echo "LUKS_PASSWORD" > /tmp/secret.key
   ```
1. Run `nixos-anywhere` to deploy the flake to the installer
   ```bash
   nix run github:nix-community/nixos-anywhere --              \
       --flake '.#pilatus'                                     \
       --build-on-remote                                       \
       --build-on remote                                       \
       --disk-encryption-keys /tmp/secret.key /tmp/secret.key  \
       --target-host NIXOS_INSTALLER_IP
   ```

## Todo

[] Currently the build cant pull/decrypt `nix-secrets`. Need to pass `ssh` key with `--extra-files` flag so that installer has access to private repo. For more infos, see [here](https://github.com/solomon-b/nixos-config/blob/main/installer/install-pc.sh#L130)
