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
      hostname = "macbook";
      alacritty.settings.font.size = 14;
    };
  };
}
