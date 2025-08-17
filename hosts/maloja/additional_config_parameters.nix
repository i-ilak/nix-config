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
      in
      {
        inherit hostname;
        baseDomain = "${hostname}.lan";
        ip = "192.168.198.144";

        paperless = {
          port = 33033;
          backupDir = "/var/lib/paperless/backup";
        };
        authelia.port = 33034;
        home-assistant.port = 33035;
      };
  };
}
