_: {
  boot.initrd.luks.devices."cryptdata" = {
    device = "/dev/disk/by-uuid/YOUR-LUKS-UUID-HERE"; # Find with: lsblk -f
    allowDiscards = true;
    bypassWorkqueues = true;
  };

  fileSystems."/share" = {
    device = "/dev/mapper/cryptdata";
    fsType = "btrfs";
    options = [
      "defaults"
      "compress=zstd"
      "noatime"
      "nodev"
      "nosuid"
    ];
  };
}
