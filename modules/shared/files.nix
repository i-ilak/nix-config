{ config, pkgs, lib, ... }:
let
  user = "iilak";
  xdg_configHome = "${config.users.users.${user}.home}/.config";
in
{
  "${xdg_configHome}/alacritty".source = ../dotfiles/shared/alacritty;
  "${xdg_configHome}/nvim".source = ../dotfiles/shared/nvim;
  "${xdg_configHome}/cmake".source = ../dotfiles/shared/cmake;
}
