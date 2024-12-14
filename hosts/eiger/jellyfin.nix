{ pkgs, lib, config, ... }:
{
  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };

  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-vaapi-driver
      vaapiVdpau
      intel-compute-runtime
      onevpl-intel-gpu # for NixOS 24.05> it will be vpl-gpu-rt
    ];
  };

  services.jellyfin = {
    enable = true;
    openFirewall = true;
    user = "jellyfin";
    group = "media";
    logDir = "/media/jellyfin/log";
    cacheDir = "/media/jellyfin/cache";
    dataDir = "/media/jellyfin/data";
    configDir = "/media/jellyfin/config";
  };
}
