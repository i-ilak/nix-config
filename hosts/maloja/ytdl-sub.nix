{
  pkgs,
  lib,
  ...
}:
let
  output = "/media/youtube";

  pathToMountUnit =
    path: (builtins.replaceStrings [ "/" ] [ "-" ] (lib.removePrefix "/" path)) + ".mount";

  ytdl-packaged-patched-cache = pkgs.writeScriptBin "ytdl-sub-patched" ''
    #!${pkgs.bash}/bin/bash
    export XDG_CACHE_HOME="/tmp/ytdl-sub"
    exec "${pkgs.ytdl-sub}/bin/ytdl-sub" "$@"
  '';
in
{
  services.ytdl-sub = {
    package = ytdl-packaged-patched-cache;
    instances.downloader = {
      enable = true;
      config = {
        configuration = {
          umask = "002";
          persist_logs = {
            logs_directory = "${output}/logs";
            keep_successful_logs = false;
          };
        };
        presets = {
          tv_show_paths = {
            overrides = {
              tv_show_directory = "${output}/tv_shows";
            };
          };

          no_shorts = {
            match_filters = {
              filters = [ "original_url!*=/shorts/" ];
            };
          };

          sponsorblock = {
            chapters = {
              sponsorblock_categories = [
                "outro"
                "selfpromo"
                "preview"
                "interaction"
                "sponsor"
                "music_offtopic"
                "intro"
              ];
              remove_sponsorblock_categories = "all";
              force_key_frames = false;
            };
          };

          sponsorblock_wait = {
            preset = [ "sponsorblock" ];
            date_range = {
              before = "today-2days";
            };
          };

          base = {
            preset = [
              "Jellyfin TV Show by Date"
              "best_video_quality"
              "tv_show_paths"
            ];
            chapters = {
              embed_chapters = true;
            };
            subtitles = {
              embed_subtitles = true;
              languages = [ "en" ];
              allow_auto_generated_subtitles = true;
            };
            ytdl_options = {
              extractor_args = {
                youtube = {
                  lang = [ "en" ];
                };
              };
            };
          };

          "TV Show Full Archive" = {
            preset = [
              "base"
              "sponsorblock_wait"
            ];
          };

          "TV Show Only Recent" = {
            preset = [
              "base"
              "sponsorblock"
              "no_shorts"
              "season_by_year__episode_by_month_day_reversed"
              "Only Recent"
            ];
            overrides = {
              only_recent_date_range = "2months";
              only_recent_max_files = 30;
            };
          };
        };
      };

      subscriptions = {
        "TV Show Only Recent" = {
          "= Science" = {
            Veritasium = "https://www.youtube.com/@veritasium";
            Kurzgesagt = "https://www.youtube.com/@kurzgesagt";
            "3Blue1Brown" = "https://www.youtube.com/@3blue1brown/videos";
          };
        };
      };
    };
  };
  users.users.ytdl-sub.extraGroups = [ "media" ];

  systemd.services."ytdl-sub-downloader" = {
    wantedBy = [ "multi-user.target" ];
    after = [ "${pathToMountUnit output}" ];
    requires = [ "${pathToMountUnit output}" ];
  };
}
