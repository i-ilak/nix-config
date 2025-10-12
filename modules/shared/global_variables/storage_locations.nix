{
  lib,
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
        inherit inernalShareDirectory;
        inherit externalShareDirectory;
        jellyfin =
          let
            base = "${inernalShareDirectory}/jellyfin";
          in
          {
            config = "${base}/config";
          };
      };
  };
}
