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
      { name = "grc"; src = pkgs.fishPlugins.grc.src; }
      { name = "z"; src = pkgs.fishPlugins.z.src; }
      { name = "fzf"; src = pkgs.fishPlugins.fzf.src; }
      { name = "fzf-fish"; src = pkgs.fishPlugins.fzf-fish.src; }
      { name = "pisces"; src = pkgs.fishPlugins.pisces.src; }
      { name = "tide"; src = pkgs.fishPlugins.tide.src; }
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
