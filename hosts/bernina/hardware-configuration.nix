{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "usbhid"
      ];
      kernelModules = [ ];
    };
    kernelModules = [ ];
    kernelPackages = pkgs.linuxPackages_rpi4;
    extraModulePackages = [ ];
  };

  hardware.enableRedistributableFirmware = true;
  hardware.enableAllHardware = lib.mkForce false;

  fileSystems."/" = lib.mkForce {
    device = "/dev/disk/by-uuid/44444444-4444-4444-8888-888888888888";
    fsType = "ext4";
  };

  swapDevices = [ ];
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}
