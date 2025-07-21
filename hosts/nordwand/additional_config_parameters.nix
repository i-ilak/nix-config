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
      domain = "vault.ilak.ch";
      acmeEmail = "ivan.ilak@hotmail.com";
    };
  };
}
