{
  config,
  ...
}:
{
  services.caddy = {
    enable = true;
    group = "caddy";
    settings =
      let
        inherit (config.sharedVariables) domain;
        certloc = "${config.security.acme.certs."${domain}".directory}";
        vaultwardenPort = toString config.services.vaultwarden.config.ROCKET_PORT;
        cloudflareCaCertPath = config.sops.secrets.cloudflared_origin_pulls_ca_cert.path;
      in
      {
        admin.listen = "off";
        auto_https.enable = false;
        logging.logs.default.level = "ERROR";
        apps = {
          http = {
            servers = {
              "${domain}" = {
                listen = [
                  "127.0.0.1:8080"
                ];
                routes = [
                  {
                    match = [
                      {
                        host = [
                          "${domain}"
                        ];
                      }
                    ];
                    handle = [
                      {
                        handler = "reverse_proxy";
                        upstreams = [
                          {
                            dial = "127.0.0.1:${vaultwardenPort}";
                          }
                        ];
                        headers.request.set = {
                          Host = [
                            "{http.request.host}"
                          ];
                          "X-Real-IP" = [
                            "{http.request.remote.host}"
                          ];
                          "X-Forwarded-For" = [
                            "{http.request.remote.host}"
                          ];
                          "X-Forwarded-Proto" = [
                            "{http.request.scheme}"
                          ];
                        };
                      }
                    ];
                    logs = {
                      logger_names = [
                        "access_${domain}"
                      ];
                    };
                    tls = {
                      certificates.load_folders = [
                        "${certloc}"
                      ];
                      protocols = [
                        "tls1.3"
                      ];
                      client_authentication = {
                        mode = "require";
                        trusted_ca_certs = [
                          "${cloudflareCaCertPath}"
                        ];
                      };
                    };
                  }
                ];
              };
            };
            loggers."access_${domain}".output.writer = {
              output = "file";
              filename = "/var/log/caddy/access-${domain}.log";
            };
          };
        };
      };
  };

  systemd.services.caddy.unitConfig = {
    Requires = [ "vaultwarden.service" ];
    After = [ "vaultwarden.service" ];
    BindsTo = [ "vaultwarden.service" ];
  };
}
