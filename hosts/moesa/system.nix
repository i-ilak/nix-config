{
  inputs,
  config,
  pkgs,
  ...
}:
{
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelParams = [
      # make it harder to influence slab cache layout
      "slab_nomerge"
      # enables zeroing of memory during allocation and free time
      # helps mitigate use-after-free vulnerabilities
      "init_on_alloc=1"
      "init_on_free=1"
      # randomizes page allocator freelist, improving security by
      # making page allocations less predictable
      "page_alloc.shuffel=1"
      # enables Kernel Page Table Isolation, which mitigates Meltdown and
      # prevents some KASLR bypasses
      "pti=on"
      # randomizes the kernel stack offset on each syscall
      # making attacks that rely on a deterministic stack layout difficult
      "randomize_kstack_offset=on"
      # disables vsyscalls, they've been replaced with vDSO
      "vsyscall=none"
      # disables debugfs, which exposes sensitive info about the kernel
      "debugfs=off"
      # certain exploits cause an "oops", this makes the kernel panic if an "oops" occurs
      "oops=panic"
      # only alows kernel modules that have been signed with a valid key to be loaded
      # making it harder to load malicious kernel modules
      # can make VirtualBox or Nvidia drivers unusable
      "module.sig_enforce=1"
      # prevents user space code excalation
      "lockdown=confidentiality"
      # "rd.udev.log_level=3"
      # "udev.log_priority=3"
    ];
  };

  nix = {
    settings.allowed-users = [ "root" ];
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 3d";
    };
    optimise = {
      automatic = true;
      dates = [ "Sun 03:00" ];
    };
  };

  system.autoUpgrade = {
    enable = true;
    flake = inputs.self.outPath;
    flags = [
      "-L"
    ];
    dates = "02:00";
    randomizedDelaySec = "45min";
  };

  environment.systemPackages = with pkgs; [
    vim
    rsync
    tree
  ];

  security = {
    protectKernelImage = true;

    # force-enable the Page Table Isolation (PTI) Linux kernel feature
    # forcePageTableIsolation = true;

    allowUserNamespaces = true;

    unprivilegedUsernsClone = config.virtualisation.containers.enable;
    allowSimultaneousMultithreading = true;
  };

  users.groups.netdev = { };
  services = {
    dbus.implementation = "broker";
    logrotate.enable = true;
    journald = {
      storage = "volatile";
      upload.enable = false;
      extraConfig = ''
        SystemMaxUse=500M
        SystemMaxFileSize=50M
      '';
    };
    fail2ban = {
      enable = true;
      maxretry = 5;
      bantime = "1h";
      ignoreIP = [
        config.networkLevelVariables.usableIpRange
      ];

      bantime-increment = {
        enable = true;
        multipliers = "1 2 4 8 16 32 64 128 256";
        maxtime = "168h";
        overalljails = true;
      };
    };
  };
}
