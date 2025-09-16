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
    sharedVariables =
      let
        hostname = "maloja";
        localDomainName = "lan";
      in
      {
        inherit hostname;
        inherit localDomainName;
        baseDomain = "${hostname}.${localDomainName}";
        publicDomain = "ilak.ch";
        ip = "192.168.1.2";
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
      };
  };
}
