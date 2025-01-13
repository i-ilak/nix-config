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
            path = lib.mkOption { type = str; };
          };
        });
        readOnly = true;
      };
  };

  config =
    mkIf cfg.enable
      (
        let
          setWallpapers = concatMapStrings
            (entry: "/usr/local/bin/desktoppr ${toString entry.desktop} ${entry.path}\n")
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
