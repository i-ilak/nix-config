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
      hostName = "bernina";

      adguardhome.port = 3000;
      unbound.port = 5335;
    };
  };
}
