{ config, pkgs, lib, ... }:
{
  options.sharedVariables = lib.mkOption {
    type = lib.types.attrs;
    default = { };
    description = "Shared variables across modules";
  };

  config = {
    sharedVariables = {
      user = "iilak";
      hostname = "mxw-dalco02";
      homeDir = "/home/iilak";
      alacritty.settings.font.size = 13;
    };
  };
}
