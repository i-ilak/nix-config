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
        shareDirectory = "/share";
      in
      {
        inherit shareDirectory;
        jellyfin =
          let
            base = "${shareDirectory}/jellyfin";
          in
          {
            config = "${base}/config";
          };
      };
  };
}
