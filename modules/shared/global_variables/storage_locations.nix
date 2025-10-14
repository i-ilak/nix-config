{
  lib,
  config,
  ...
}:
{
  options.storageVariables = lib.mkOption {
    type = lib.types.attrs;
    default = { };
    description = "Shared variables across systems";
  };

  config = {
    storageVariables =
      let
        inernalShareDirectory = "/share";
        externalShareDirectory = "/share/external";
      in
      {
        general = {
          inherit inernalShareDirectory;
          inherit externalShareDirectory;
        };
        services = {
          jellyfin =
            let
              base = "${inernalShareDirectory}/jellyfin";
            in
            {
              inherit base;
              config = "${base}/config";
              allowedIpRange = [
                config.networkLevelVariables.ipMap.maloja
              ];
            };
          paperless =
            let
              base = "${inernalShareDirectory}/paperless";
            in
            {
              inherit base;
              allowedIpRange = [
                config.networkLevelVariables.ipMap.maloja
              ];
            };
          navidrome =
            let
              base = "${externalShareDirectory}/navidrome";
            in
            {
              inherit base;
              allowedIpRange = [
                config.networkLevelVariables.ipMap.maloja
              ];
            };
          immich =
            let
              base = "${externalShareDirectory}/immich";
            in
            {
              inherit base;
              allowedIpRange = [
                config.networkLevelVariables.ipMap.maloja
              ];
            };
        };
      };
  };
}
