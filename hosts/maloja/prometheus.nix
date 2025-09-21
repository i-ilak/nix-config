{
  config,
  ...
}:
let
  inherit (config.sharedVariables) internalDomain;
in
{
  services.prometheus = {
    enable = true;
    inherit (config.sharedVariables.prometheus) port;

    exporters = {
      unbound = {
        enable = true;
        inherit (config.sharedVariables.unbound) port;
        unbound = {
          host = "unix:///${config.services.unbound.settings.remote-control.control-interface}";
          ca = null;
          certificate = null;
          key = null;
        };
        group = "unbound";
        listenAddress = "127.0.0.1";
      };
      node = {
        enable = true;
        listenAddress = "127.0.0.1";
        openFirewall = false;
        port = 9100;
        extraFlags = [ "--collector.netdev.address-info" ];
      };
    };
    scrapeConfigs = [
      {
        job_name = "monitoring-maloja";
        basic_auth = {
          username = "prometheus_server";
          password_file = config.sops.secrets.monitoring_auth_password.path;
        };
        scheme = "https";
        scrape_interval = "30s";
        static_configs = [
          {
            targets = [
              "node-exporter.${internalDomain}:${builtins.toString config.sharedVariables.internalReverseProxyPort}"
              "unbound-exporter.${internalDomain}:${builtins.toString config.sharedVariables.internalReverseProxyPort}"
            ];
          }
        ];
      }
    ];
  };
}
