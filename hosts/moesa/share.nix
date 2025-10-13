_: {
  boot = {
    kernelModules = [ "btrfs" ];
    initrd.luks.devices."cryptdata" = {
      device = "/dev/disk/by-uuid/YOUR-NEW-HDD-UUID-HERE";
      name = "cryptdata";
      askPassword = true;
      allowDiscards = false;
    };
  };

  fileSystems."/share" = {
    fsType = "btrfs";
    device = "/dev/mapper/cryptdata";
    options = [
      # Standard options for a secure, non-boot volume
      "defaults"
      "nodev"
      "nosuid"
      # Btrfs-specific performance options
      "compress-force=zstd" # Ensure Zstd is always attempted
      "noatime"
      "ssd_spread"
    ];
  };

  # To create the Btrfs volume from scratch (assuming /dev/sda is the drive):
  # 1. Partition the drive:
  #    $ sudo gdisk /dev/sda
  # 2. Encrypt the partition (/dev/sda1):
  #    $ sudo cryptsetup luksFormat /dev/sda1
  # 3. Unlock the container to create the mapper device (/dev/mapper/cryptdata):
  #    $ sudo cryptsetup luksOpen /dev/sda1 cryptdata
  # 4. Create the Btrfs filesystem on the unlocked device:
  #    $ sudo mkfs.btrfs -f /dev/mapper/cryptdata
  # 5. OPTIONAL: To ensure data/metadata is explicitly set to 'single' (no mirror):
  #    $ sudo mount /dev/mapper/cryptdata /mnt
  #    $ sudo btrfs balance start -mconvert=single -dconvert=single /mnt
  #    $ sudo umount /mnt
  # 6. Apply NixOS config and reboot. The system will prompt for the LUKS password.
}
