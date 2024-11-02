{
  config,
  pkgs,
  lib,
  ...
}: let
  user = "iilak";
  home = builtins.getEnv "HOME";
  xdg_configHome = "${home}/.config";
in {
  "${xdg_configHome}/wallpapers".source = ../dotfiles/wallpapers;
}
