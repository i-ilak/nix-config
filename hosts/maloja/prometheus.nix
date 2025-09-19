{
  config,
  ...
}:
{
  services.prometheus = {
    enable = true;
    inherit (config.sharedVariables.prometheus) port;

    exporters = {
      unbound = {
        enable = true;
        listenAddress = "127.0.0.1";
        inherit (config.sharedVariables.unbound) port;
      };
    };
  };
}
