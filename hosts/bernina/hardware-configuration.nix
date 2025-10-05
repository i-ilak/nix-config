{
  lib,
  pkgs,
  modulesPath,
  ...
}:
{
  # imports = [
  #   (modulesPath + "/installer/scan/not-detected.nix")
  # ];
  #
  # boot = {
  #   initrd = {
  #     availableKernelModules = [
  #       "xhci_pci"
  #       "usbhid"
  #     ];
  #     kernelModules = [ ];
  #   };
  #   kernelModules = [ ];
  #   kernelPackages = pkgs.linuxPackages_rpi4;
  #   extraModulePackages = [ ];
  #   loader = {
  #     grub.enable = false;
  #     generic-extlinux-compatible.enable = true;
  #   };
  # };
  #
  # hardware.enableRedistributableFirmware = true;
  # hardware.enableAllHardware = lib.mkForce false;
  #
  # fileSystems."/" = lib.mkForce {
  #   device = "/dev/disk/by-uuid/44444444-4444-4444-8888-888888888888";
  #   fsType = "ext4";
  # };
  #
  # swapDevices = [ ];
  # nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_rpi4;
    initrd.availableKernelModules = [
      "xhci_pci"
      "usbhid"
      "usb_storage"
    ];
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };
}
