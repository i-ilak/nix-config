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
    openFirewall = false;
    user = "jellyfin";
    group = "jellyfin";
    logDir = "${jellyfinFolder}/log";
    cacheDir = "${jellyfinFolder}/cache";
    dataDir = "${jellyfinFolder}/data";
    configDir = "${jellyfinFolder}/config";
  };
  users.users.jellyfin.extraGroups = [ "media" ];
}
