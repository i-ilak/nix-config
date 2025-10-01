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
      hostname = "bernina";
      publicDomain = "ilak.ch";
      ip = "192.168.1.2";
      gatewayIp = "192.168.1.1";

      adguardhome.port = 3000;
      unbound.port = 5335;
    };
  };
}
