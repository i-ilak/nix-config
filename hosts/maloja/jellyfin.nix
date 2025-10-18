{
  pkgs,
  config,
  ...
}:
let
  inherit (config.storageVariables.services) jellyfin;
  baseOnDevice = "/var/lib/jellyfin";
  logDir = "${baseOnDevice}/log";
  cacheDir = "${baseOnDevice}/cache";
  configDir = "${baseOnDevice}/config";
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
    inherit (jellyfin) dataDir;
    inherit configDir;
    inherit logDir;
    inherit cacheDir;
  };
  users.users.jellyfin.extraGroups = [ "media" ];
}
