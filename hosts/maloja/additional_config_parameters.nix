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
        publicDomain = "ilak.ch";
        localDomainName = "lan";
      in
      {
        inherit hostname;
        inherit publicDomain;
        inherit localDomainName;

        baseDomain = "${hostname}.${localDomainName}";
        internalDomain = "${hostname}.${publicDomain}";

        ip = "192.168.1.2";
        ipv6 = "fd00:ad:ad::2";
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
        prometheus.port = 33040;
        grafana.port = 33041;

        internalReverseProxyPort = 4443;
      };
  };
}
