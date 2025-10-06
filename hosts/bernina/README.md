# Bernina

## To-Do

- Need to figure out a workflow that works and is sustainable...
  - Currently, I can build a SD card image with
    ```bash
    nix build .#nixosConfigurations.bernina.config.system.build.sdImage
    ```
    Problems with this approach:
    - Can only be done in docker, since I need `aarch64-linux`
    - As a consequence I am missing all secrets to access `github:i-ilak/nix-secrets`, which is needed to build the image
    - Even assuming I solve this issue, I dont have a way to deploy the `ssh` key needed to decrypt the sops files.
      This seems to be a dead end.
  - I would prefer to do it the same way as I do with the rest of my systems, i.e.
    - Create a bootable SD card (easy, download newst image and use RPi image flasher to write it to the sd card)
    - Use `nixos-anywhere` with `disko` to deploy it to the system
    - Problem with this: No easy way to create what is necessary with disko...

# Solution

A somewhat cumbersome, but doable solution is the following:

1. Download the correct NixOS image and flash it onto the Pi over the Pi flasher tool.
1. Go through the standard setup procedure for NixOS and install it.
1. Once installed, reboot the system, and get the age key from the `/etc/ssh/ssh_host_ed25519_key`.
1. On `plessur` add this key to `.sops.yaml` and update your secrets.
1. Create a ssh key and add it to github so that the Pi has access to your flakes.
1. Run
   ```
   sudo nixos-rebuild switch --flake github:i-ilak/nix-config#bernina
   ```
   on the Pi.

If you didn't fuck up, the system should be correctly deployed.
