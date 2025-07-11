{ lib
, ...
}:
{
  options.sharedVariables = lib.mkOption {
    type = lib.types.attrs;
    default = { };
    description = "Shared variables across modules";
  };

  config = {
    sharedVariables = {
      user = "iilak";
      hostname = "mxw-dalco01";
      homeDir = "/home/iilak";
      alacritty.settings.font.size = 13;
      i3.modifier = "Mod4";
      polybar = {
        monitor = "VNC-0";
        network.interface = "eno1";
      };
    };
  };
}
