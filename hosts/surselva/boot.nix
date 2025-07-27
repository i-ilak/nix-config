_: {
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelModules = [
      "dm_mod"
      "dm_crypt"
    ];
    kernel.sysctl = {
      # Maximum receive buffer size for all UDP sockets (in bytes)
      # Cloudflared needs at least 7 MiB = 7168 KiB = 7340032 bytes
      "net.core.rmem_max" = 7340032; # Allow up to 7 MiB receive buffer per socket
      "net.core.wmem_max" = 7340032; # Allow up to 7 MiB send buffer per socket

      # UDP memory thresholds: min, pressure, max (in pages; 1 page = usually 4096 bytes)
      # You want the "max" to be large enough to support many 7 MiB sockets if needed.
      "net.ipv4.udp_mem" = "98304 131072 262144"; # Roughly allows 384 MiB max UDP memory
      "net.ipv4.udp_rmem_min" = 16384; # Still 16 KiB minimum
      "net.ipv4.udp_wmem_min" = 16384; # Still 16 KiB minimum
    };
  };
}
