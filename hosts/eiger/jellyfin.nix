{
  pkgs,
  ...
}:
let
  jellyfinFolder = "/media/jellyfin";
in
{
  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-vaapi-driver
      vaapiVdpau
      intel-compute-runtime
      vpl-gpu-rt
    ];
  };

  services.jellyfin = {
    enable = true;
    openFirewall = true;
    user = "jellyfin";
    group = "jellyfin";
    logDir = "${jellyfinFolder}/log";
    cacheDir = "${jellyfinFolder}/cache";
    dataDir = "${jellyfinFolder}/data";
    configDir = "${jellyfinFolder}/config";
  };
  users.users.jellyfin.extraGroups = [ "media" ];

  systemd.services.jellyfin.serviceConfig = {
    Restart = "on-failure";
    StateDirectory = "jellyfin";
    CacheDirectory = "jellyfin";

    ReadWritePaths = [
      "/var/lib/jellyfin"
      "/var/cache/jellyfin"
      "/media/jellyfin"
    ];

    BindReadOnlyPaths = [
      "/media/movies"
      "/media/tv"
      "/media/anime"
      "/nix/store"
      "/etc/ssl/certs" # If it needs SSL certificates
      "/etc/resolv.conf" # If it needs DNS
    ];

    PrivateTmp = true;
    PrivateDevices = false;
    DeviceAllow = "/dev/dri/renderD128";
    PrivateUsers = true;
    ProtectSystem = "strict";
    ProtectHome = true;

    NoNewPrivileges = true;
    RestrictSUIDSGID = true;

    MemoryDenyWriteExecute = true;
    LockPersonality = true;

    ProtectClock = true;
    ProtectControlGroups = true;
    ProtectHostname = true;
    ProtectKernelLogs = true;
    ProtectKernelModules = true;
    ProtectKernelTunables = true;
    RemoveIPC = true;

    RestrictAddressFamilies = [
      "AF_NETLINK"
      "AF_INET"
      "AF_INET6"
    ];

    RestrictNamespaces = true;
    RestrictRealtime = true;

    SystemCallArchitectures = "native";
    SystemCallErrorNumber = "EPERM";
    SystemCallFilter = [
      "@system-service"
      "~@cpu-emulation"
      "~@debug"
      "~@keyring"
      "~@memlock"
      "~@obsolete"
      "~@privileged"
      "~@setuid"
    ];
  };
}
