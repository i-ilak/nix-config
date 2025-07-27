# Todo

- [ ] Get it to actually work. Seems to be an issue with `disko + impermanance + sops`. Currently it runs through and then fails when booting after the LUKS password has been inputted
- [ ] Increase `tmpfs` of root to 10 GB with
  ```bash
  sudo mount -o remount,size=10G /
  ```
