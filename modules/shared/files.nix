{ config, pkgs, lib, ... }:
let
  user = "iilak";
in
{
  "alacritty".source = ../dotfiles/shared/alacritty;
  "nvim".source = ../dotfiles/shared/nvim;
  "cmake".source = ../dotfiles/shared/cmake;
}
