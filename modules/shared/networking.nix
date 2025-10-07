{
  lib,
  ...
}:
{
  options.networkLevelVariables = lib.mkOption {
    type = lib.types.attrs;
    default = { };
    description = "Shared variables across systems";
  };

  config = {
    networkLevelVariables = {
      publicDomain = "ilak.ch";
      ipMap = {
        bernina = "192.168.1.2";
        maloja = "192.168.1.3";
        moesa = "192.168.1.4";
      };
      gatewayIp = "192.168.1.1";
    };
  };
}
