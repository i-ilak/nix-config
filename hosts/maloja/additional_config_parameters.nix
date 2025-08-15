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
        baseDir = "/media/paperless";

      in
      {
        paperless = {
          inherit baseDir;
          port = 9293;
          mediaDir = "${baseDir}/media";
          dataDir = "${baseDir}/data";
          backupDir = "/media/backup/paperless";
        };
        authelia.port = 9091;
        home-assistant.port = 2342;
        domain = "ilak.ch";
        ip = "192.168.198.144";
      };
  };
}
