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
