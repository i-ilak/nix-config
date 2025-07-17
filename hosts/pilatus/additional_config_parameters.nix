{
  lib,
  ...
}:
{
  options.sharedVariables = lib.mkOption {
    type = lib.types.attrs;
    default = { };
    description = "Shared variables across modules";
  };

  config = {
    sharedVariables = {
      user = "dev";
      homeDir = "/home/dev";
      hostname = "pilatus";
      alacritty.settings.font.size = 13;
      i3.modifier = "Mod1";
      polybar = {
        monitor = "Virtual-1";
        network.interface = "ens160";
      };
    };
  };
}
