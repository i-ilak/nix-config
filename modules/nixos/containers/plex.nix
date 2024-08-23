{ config, pkgs, ... }:
{
  virtualisation.oci-containers.containers."plex" = {
    autoStart = true;
    image = "plexinc/pms-docker";
    volumes = [
      "/media/containers/plex/config:/config"
      "/media/containers/plex/transcode:/transcode"
      "/media/data:/data"
    ];
    ports = [ 
        "32400:32400"
        "8324:8324"
        "32469:32469"
        "1900:1900"
        "32410:32410"
        "32412:32412"
        "32413:32413"
        "32414:32414"
    ];
    environment = {
    };
  };
}
