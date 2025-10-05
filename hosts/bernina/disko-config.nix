{
  pkgs,
  inputs,
  ...
}:
let
  configTxt = pkgs.writeText "config.txt" ''
    [pi4]
    kernel=u-boot-rpi4.bin
    enable_gic=1

    # Otherwise the resolution will be weird in most cases, compared to
    # what the pi3 firmware does by default.
    disable_overscan=1

    # Supported in newer board revisions
    arm_boost=1

    [cm4]
    # Enable host mode on the 2711 built-in XHCI USB controller.
    # This line should be removed if the legacy DWC2 controller is required
    # (e.g. for USB device mode) or if USB support is not required.
    otg_mode=1

    [all]
    # Boot in 64-bit mode.
    arm_64bit=1

    # U-Boot needs this to work, regardless of whether UART is actually used or not.
    # Look in arch/arm/mach-bcm283x/Kconfig in the U-Boot tree to see if this is still
    # a requirement in the future.
    enable_uart=1

    # Prevent the firmware from smashing the framebuffer setup done by the mainline kernel
    # when attempting to show low-voltage or overtemperature warnings.
    avoid_warnings=1
  '';
in
{
  disko = {
    memSize = 6144;
    imageBuilder = {
      enableBinfmt = true;
      pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
      kernelPackages = inputs.nixpkgs.legacyPackages.x86_64-linux.linuxPackages_latest;
    };
    devices = {
      disk = {
        disk1 = {
          imageSize = "20G";
          type = "disk";
          device = "/dev/mmcblk1";
          postCreateHook = ''
            lsblk
            sgdisk -A 1:set:2 /dev/vda
          '';
          content = {
            type = "gpt";
            partitions = {
              firmware = {
                size = "30M";
                priority = 1;
                type = "0700";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/firmware";
                  postMountHook = toString (
                    pkgs.writeScript "postMountHook.sh" ''
                      (cd ${pkgs.raspberrypifw}/share/raspberrypi/boot && cp bootcode.bin fixup*.dat start*.elf *.dtb /mnt/firmware/)
                      cp ${pkgs.ubootRaspberryPi4_64bit}/u-boot.bin /mnt/firmware/u-boot-rpi4.bin
                      cp ${configTxt} /mnt/firmware/config.txt
                    ''
                  );
                };
              };
              boot = {
                size = "1G";
                type = "EF00";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                };
              };
              root = {
                name = "root";
                size = "100%";
                content = {
                  type = "filesystem";
                  extraArgs = [ "--compression=zstd" ];
                  format = "bcachefs";
                  mountpoint = "/";
                  postMountHook = toString (
                    pkgs.writeScript "postMountHook.sh" ''
                      touch /mnt/disko-first-boot
                    ''
                  );
                };
              };
            };
          };
        };
      };
    };
  };
}
