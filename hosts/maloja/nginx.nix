{
  config,
  pkgs,
  ...
}:
{
  sops = {
    secrets = {
      monitoring_auth_password_bcrypt = {
        key = "monitoring/auth_password_bcrypt";
        owner = "nginx";
        group = "nginx";
        mode = "0640";
      };
    };
    templates.nginx_user_file.content = ''
      prometheus:${config.sops.placeholder.monitoring_auth_password_bcrypt}
    '';
  };

  services.nginx =
    let
      inherit (config.sharedVariables) internalDomain;
    in
    {
      enable = true;
      defaultSSLListenPort = config.sharedVariables.internalReverseProxyPort;

      virtualHosts =
        let
          mkExporter = port: {
            onlySSL = true;
            useACMEHost = "${internalDomain}";
            locations."/".proxyPass = "http://localhost:${toString port}";
            basicAuthFile = config.sops.templates.nginx_user_file.path;
          };
        in
        {
          "unbound-exporter.${internalDomain}" = mkExporter config.services.prometheus.exporters.unbound.port;
          "node-exporter.${internalDomain}" = mkExporter config.services.prometheus.exporters.node.port;
        };
    };
}
