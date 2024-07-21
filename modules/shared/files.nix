{ config, pkgs, lib, ... }:
let
  user = "iilak";
  home = builtins.getEnv "HOME";
  xdg_configHome = "${home}/.config";
in
{
  "${xdg_configHome}/alacritty".source = ../dotfiles/shared/alacritty;
  "${xdg_configHome}/nvim".source = ../dotfiles/shared/nvim;
  "${xdg_configHome}/cmake".source = ../dotfiles/shared/cmake;
  "${xdg_configHome}/wallpapers".source = ../dotfiles/wallpapers;
}
