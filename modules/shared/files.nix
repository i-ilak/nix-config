_:
let
  home = builtins.getEnv "HOME";
  xdg_configHome = "${home}/.config";
in
{
  "${xdg_configHome}/ghostty".source = ../../dotfiles/shared/ghostty;
  "${xdg_configHome}/wallpapers".source = ../../dotfiles/wallpapers;
}
