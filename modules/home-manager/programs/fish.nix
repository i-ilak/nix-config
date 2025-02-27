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
    '';
    plugins = [
      { name = "grc"; inherit (pkgs.fishPlugins.grc) src; }
      { name = "z"; inherit (pkgs.fishPlugins.z) src; }
      { name = "fzf"; inherit (pkgs.fishPlugins.fzf) src; }
      { name = "fzf-fish"; inherit (pkgs.fishPlugins.fzf-fish) src; }
      { name = "pisces"; inherit (pkgs.fishPlugins.pisces) src; }
      { name = "tide"; inherit (pkgs.fishPlugins.tide) src; }
    ];
    shellAliases = {
      vim = "nvim";
      ip = "ip --color=auto";
      ll = "ls -lFha --color=auto";
      ls = "ls --color=auto";
      mkdir = "mkdir -p";
      diff = "colordiff";
      df = "df -Tha --total";
      du = "du -ach";
      ps = "ps auxf";
      ssh = "TERM=xterm-256color ssh";
    };
  };
}
