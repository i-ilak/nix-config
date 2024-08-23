{ config, pkgs, ... }:
{
  virtualisation.oci-containers.containers."jellyfin" = {
    autoStart = true;
    image = "jellyfin/jellyfin";
    volumes = [
      "/media/containers/jellyfin/config:/config"
      "/media/containers/jellyfin/cache:/cache"
      "/media/containers/jellyfin/log:/log"
      "/media/movies:/movies"
      "/media/tv_series:/tv"
    ];
    ports = [ "8096:8096" ];
    environment = {
      JELLYFIN_LOG_DIR = "/log";
    };
  };
}
