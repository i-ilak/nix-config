_:
let
  output = "/home/worker/yt";
in
{
  services.ytdl-sub = {
    user = "worker";
    group = "media";
    instances.downloader = {
      enable = true;
      config = {
        presets = {
          yearly_recent = {
            date_range.after = "today-1year";
            output_options = {
              keep_files_after = "today-1year";
              keep_max_files = 20;
            };
          };

          with_subtitles.subtitles = {
            embed_subtitles = true;
            languages = [ "en" ];
          };
          channel.preset = [
            "Jellyfin TV Show by Date"
            "best_video_quality"
          ];
        };
      };

      subscriptions =
        {
          __preset__.overrides = {
            music_directory = "${output}/music";
            music_video_directory = "${output}/music_videos";
            tv_show_directory = "${output}/tv_shows";
            only_recent_date_range = "2months";
            only_recent_max_files = 30;
          };

          "Jellyfin TV Show by Date" = {
            Documentaries = {
              "NOVA PBS" = { urls = [ "https://www.youtube.com/@novapbs" ]; };
            };
          };
        };
    };
  };
}
