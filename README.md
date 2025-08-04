# `nix` Configuration

[![Nix Config CI](https://github.com/i-ilak/nix-config/actions/workflows/flake-check.yml/badge.svg)](https://github.com/i-ilak/nix-config/actions/workflows/flake-check.yml)

The configuration I use for all my systems.
It is based on [Dustin Lyons `nix-config`](https://github.com/dustinlyons/nixos-config), but his split for host machines didn't really work for me.
I have `macOS`, `NixOS` and general Linux systems (i.e. non-NixOS systems that only use `home-manager` to configure a users home), and I wanted to make sure that this config accommodated all of them.

Currently configured systems are:

- `macbook`: Personal laptop.
- `mxw-dalco01`: Workstation used at my current employer.
- `maloja`: Intel Nuc. Used to host some small services and experiment.
- `albula`: VM that I use to develop things on Linux as needed.
