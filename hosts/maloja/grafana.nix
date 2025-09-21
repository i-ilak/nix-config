{
  config,
  ...
}:
{
  sops.secrets = {
    grafana_admin_password = {
      key = "grafana/admin_password";
      owner = "grafana";
      group = "grafana";
      mode = "0600";
    };
  };

  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "127.0.0.1";
        http_port = config.sharedVariables.grafana.port;
        domain = "monitoring.${config.sharedVariables.publicDomain}";
        root_url = "https://monitoring.${config.sharedVariables.publicDomain}";
      };

      auth = {
        disable_login_form = false;
        disable_signout_menu = false;
      };

      security = {
        admin_user = "admin";
        admin_password = "$__file{${config.sops.secrets.grafana_admin_password.path}}";
      };
    };

    provision =
      let
        inherit (config.sharedVariables) internalDomain;
      in
      {
        enable = true;
        datasources.settings.datasources = [
          {
            name = "Node Exporter";
            type = "prometheus";
            access = "proxy";
            url = "https://node-exporter.${internalDomain}:${builtins.toString config.sharedVariables.internalReverseProxyPort}";
            basicAuth = true;
            basicAuthUser = "prometheus_server";
            secureJsonData = {
              basicAuthPassword = "$__file{${config.sops.secrets."monitoring_auth_password".path}}";
            };
            jsonData = {
              tlsSkipVerify = true;
            };
            isDefault = true;
          }
        ];
      };
  };
}
