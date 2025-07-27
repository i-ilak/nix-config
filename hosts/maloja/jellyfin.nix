{
  pkgs,
  ...
}:
{
  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      # intel-media-driver
      # intel-vaapi-driver
      # vaapiVdpau
      # intel-compute-runtime
      # vpl-gpu-rt
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
