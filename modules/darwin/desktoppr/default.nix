{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.local.desktoppr;
  inherit (pkgs) stdenv;
in
{
  options = {
    local.desktoppr.enable = mkOption {
      description = "Enable setting of wallpaper with `desktoppr`";
      default = stdenv.isDarwin;
      example = false;
    };

    local.desktoppr.wallpapers = mkOption
      {
        description = "Wallpapers to be set for different screens!";
        type = with types; listOf (submodule {
          options = {
            desktop = lib.mkOption { type = int; };
            name = lib.mkOption { type = str; };
          };
        });
        readOnly = true;
      };
  };

  config =
    mkIf cfg.enable
      (
        let
          repo = pkgs.fetchFromGitHub {
            owner = "i-ilak";
            repo = "wallpapers";
            rev = "main";
            sha256 = "sha256-JonOmR1gdNKShqWNHx0AvgpncclwMMZsJYldeuLanLs=";
          };
          wallpaper_map = builtins.fromJSON (builtins.readFile "${repo}/wallpapers.json");
          setWallpapers = concatMapStrings
            (entry:
              let
                wallpaperUrl = wallpaper_map.wallpapers.${entry.name};
              in
              "/usr/local/bin/desktoppr ${toString entry.desktop} '${wallpaperUrl}'\n"
            )
            cfg.wallpapers;
        in
        {
          system.activationScripts.postUserActivation.text = ''
            echo >&2 "Setting up wallpapers..."
            ${setWallpapers} 
          '';
        }
      );
}
