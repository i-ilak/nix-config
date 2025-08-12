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
        domain = "ilak.ch";
      };
  };
}
