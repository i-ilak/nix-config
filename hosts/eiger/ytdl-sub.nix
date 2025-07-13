_:
{
  services.ytdl-sub = {
    enable = true;
    user = "ytdl";
    group = "media";
    instances.downloader = {
      enable = true;

      config = {
        download_dir = "/home/worker/youtube";

        retention_policy = {
          max_age = "2w";
          min_storage = "10G";
        };
      };

      subscriptions = [
        {
          url = "https://www.youtube.com/@veritasium";
          name = "Veritasium";
        }
      ];
    };
  };
}
