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
      hostname = "maloja";
      publicDomain = "ilak.ch";
      ip = "192.168.1.3";
      gatewayIp = "192.168.1.1";

      paperless = {
        port = 33033;
        backupDir = "/var/lib/paperless/backup";
      };
      authelia.port = 33034;
      home-assistant = {
        port = 33035;
        backupDir = "/var/lib/hass/backups";
      };
      adguardhome.port = 3000;
      unbound.port = 5335;
      atticd.port = 33080;
    };
  };
}
