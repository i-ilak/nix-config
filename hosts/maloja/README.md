# Todo

- [x] Need to write a backup & restoring service for `acme-${publicDomain}.service`.
      The issue here is that `Lets encypt` only gives out 5 certificates per **week** for the same set of domains.
      If you are working with NixOS redeployments, which each time trigger requests for new certificates, this is problematic.
      Solution: we need to back up `/var/lib/acme` and restore it on redeployment.
      There is already an example of this in `paperless.nix`.

  - Be careful to also backup the hidden folders, i.e. `.lego` and `.mimica`.
  - Permissions will be an issue, i.e. there are quite a few certificates in those directories and all of them need to have a particular set of permissions.
  - [x] B2 Bucket needs to be created.

- [ ] Home Assistant also needs backing up.
      Here we already have a bit more ready, i.e. bucket and secrets are done.
  - [ ] Need to get flake `i-ilak/ha-cli` to correctly build in `nix-config`
  - [ ] Figure out how to obtain a list of `slugs` for the `ha backups restore SLUG` command, i.e. how do I know what the latest slug is?
  - Think a bit about timing.
    Backups run between 0445-0545, so I guess a good time to backup would be directly afterwards?
