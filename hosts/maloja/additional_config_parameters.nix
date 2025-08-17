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
        baseDirPaperless = "/tmp/paperless";
        hostname = "maloja";
      in
      {
        inherit hostname;
        baseDomain = "${hostname}.lan";
        ip = "192.168.198.144";

        paperless = {
          baseDir = baseDirPaperless;
          port = 33033;
          mediaDir = "${baseDirPaperless}/media";
          dataDir = "${baseDirPaperless}/data";
          backupDir = "/tmp/backup/paperless";
        };
        authelia.port = 33034;
        home-assistant.port = 33035;
      };
  };
}
