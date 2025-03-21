{ config
, lib
, pkgs
, ...
}:
let
  inherit (config.sharedVariables) homeDir;
  inherit (config.sharedVariables) hostname;
in
{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting # Disable greeting

      set -x FZF_DEFAULT_COMMAND "fd . $HOME"
      set -x FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
      set -x FZF_ALT_C_COMMAND "fd -t d . $HOME"
    '';
    plugins = [
      { name = "grc"; inherit (pkgs.fishPlugins.grc) src; }
      { name = "z"; inherit (pkgs.fishPlugins.z) src; }
      { name = "fzf"; inherit (pkgs.fishPlugins.fzf) src; }
      { name = "fzf-fish"; inherit (pkgs.fishPlugins.fzf-fish) src; }
      { name = "pisces"; inherit (pkgs.fishPlugins.pisces) src; }
      { name = "tide"; inherit (pkgs.fishPlugins.tide) src; }
      { name = "plugin-git"; inherit (pkgs.fishPlugins.plugin-git) src; }
    ];
    shellAliases = {
      vim = "nvim";
      ip = "ip --color=auto";
      ll = "eza -l";
      ls = "eza -g";
      tree = "eza -T";
      mkdir = "mkdir -p";
      diff = "colordiff";
      df = "df -Tha --total";
      du = "du -ach";
      ps = "procs";
    };
    shellInitLast = ''
      set -gx PATH ${config.sharedVariables.homeDir}/.cargo/bin $PATH
    '';
  };
}
