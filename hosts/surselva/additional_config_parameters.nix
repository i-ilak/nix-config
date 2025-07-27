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
      domain = "ilak.ch";
      acmeEmail = "ivan.ilak@hotmail.com";
      authelia.port = 9091;
      authentik.port = 9000; # HTTP
    };
  };
}
