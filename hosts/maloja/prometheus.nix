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
        port = 9167;
        listenAddress = "127.0.0.1";
        unbound = {
          host = "unix:///${config.services.unbound.settings.remote-control.control-interface}";
          ca = null;
          certificate = null;
          key = null;
        };
        group = "unbound";
      };
      node = {
        enable = true;
        port = 9100;
        listenAddress = "127.0.0.1";
        openFirewall = false;
        extraFlags = [
          "--collector.netdev.address-info"
          "--collector.filesystem.mount-points-exclude=^/(dev|proc|sys|run/user)($|/)"
        ];
      };
      systemd = {
        enable = true;
        port = 9558;
        listenAddress = "127.0.0.1";
      };
    };
    scrapeConfigs = [
      {
        job_name = "prometheus";
        static_configs = [
          {
            targets = [ "127.0.0.1:${builtins.toString config.sharedVariables.prometheus.port}" ];
          }
        ];
      }
      {
        job_name = "node";
        static_configs = [
          {
            targets = [ "127.0.0.1:9100" ];
          }
        ];
      }
      {
        job_name = "unbound";
        static_configs = [
          {
            targets = [ "127.0.0.1:9167" ];
          }
        ];
      }
      {
        job_name = "systemd";
        static_configs = [
          {
            targets = [ "127.0.0.1:9558" ];
          }
        ];
      }
    ];
    globalConfig = {
      scrape_interval = "15s";
      evaluation_interval = "15s";
    };
    retentionTime = "30d";
  };
}
