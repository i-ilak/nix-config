_:
let
  home = builtins.getEnv "HOME";
  xdg_configHome = "${home}/.config";

  sharedFiles = import ../../modules/shared/files.nix { };
  file = {
    "${xdg_configHome}/ccache/ccache.conf".source = ../../dotfiles/linux/ccache/ccache.conf;
  } // sharedFiles;
in
file
