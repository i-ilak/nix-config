# `nix` Configuration

[![Statix Lint](https://github.com/i-ilak/nix-config/actions/workflows/lint.yml/badge.svg)](https://github.com/i-ilak/nix-config/actions/workflows/lint.yml)

The configurations I use for all my systems.
It is based on [Dustin Lyons `nix-config`](https://github.com/dustinlyons/nixos-config), but his split for host machines didn't really work for me, so I gave it a twist.
I have `macOS`, `NixOS` and general Linux systems (i.e. non-NixOS systems that only use `home-manager` to configure a users home), and I wanted to make sure that this config accommodates all of them.
Some systems are more involved than others, but this started out as an experiment almost 2 years ago and so far, I'm still having fun with it.

Currently configured systems are:

- `plessur`: Personal laptop, macOS, configured over [`nix-darwin`](https://github.com/nix-darwin/nix-darwin).
- `maloja`: Homelab. Currently hosts only services that I do **not** want to expose to the public internet.
  - Everything that is worth backing up (`paperless`, `home-assistant`, `acme` account credentials, etc.) is backed up into Backblaze B2 buckets over S3 conformant API.
  - Get valid `Let's Encrypt` wildcard certificates for my domain over `dns-01` challange to host only on local network but offer `https`.
  - Setup:
    - `jellyfin` to watch movies, shows.
    - `yt-dl` to track and download videos from channels I care about and host them over `jellyfin`.
    - `paperless-ngx` to never have to store anything in a physical folder again.
    - `home-assistant` to check on IoT devices at home.
- `albula`: VM that I use to develop things on Linux.
- `mxw-dalco01`: Workstation used at my current employer.

## Notes

Throughout my configs I use [`sops-nix`](https://github.com/Mic92/sops-nix), a beautiful piece of software, for managing secrets declaratively.
These secrets are hosted in a private github repo, encrypted over [`sops`](https://github.com/getsops/sops).
Consequently, I you check out this repo, be sure to also spend some time investigating on how the secrets management is setup.
