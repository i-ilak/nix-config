{
  config,
  pkgs,
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
        protocol = "http";
        http_addr = "127.0.0.1";
        http_port = config.sharedVariables.grafana.port;
        domain = "monitoring.${config.sharedVariables.publicDomain}";
        root_url = "https://monitoring.${config.sharedVariables.publicDomain}";
        serve_from_sub_path = false;
      };

      security = {
        admin_user = "admin";
        admin_password = "$__file{${config.sops.secrets.grafana_admin_password.path}}";
        secret_key = "$__file{${config.sops.secrets.grafana_admin_password.path}}";
        disable_gravatar = true;
        cookie_secure = true;
        cookie_samesite = "lax";
        strict_transport_security = true;
      };

      auth = {
        disable_login_form = false;
        disable_signout_menu = false;
      };

      "auth.anonymous" = {
        enabled = false;
      };

      analytics = {
        reporting_enabled = false;
        check_for_updates = false;
      };
    };

    provision = {
      enable = true;

      datasources.settings = {
        apiVersion = 1;
        deleteDatasources = [
          {
            name = "Prometheus";
            orgId = 1;
          }
        ];
        datasources = [
          {
            name = "Prometheus";
            type = "prometheus";
            access = "proxy";
            orgId = 1;
            uid = "prometheus-uid";
            url = "http://127.0.0.1:${builtins.toString config.sharedVariables.prometheus.port}";
            isDefault = true;
            jsonData = {
              timeInterval = "15s";
              queryTimeout = "60s";
              httpMethod = "POST";
            };
            editable = false;
          }
        ];
      };

      dashboards.settings = {
        apiVersion = 1;
        providers = [
          {
            name = "Default";
            orgId = 1;
            folder = "";
            type = "file";
            disableDeletion = false;
            updateIntervalSeconds = 10;
            allowUiUpdates = true;
            options = {
              path = "/var/lib/grafana/dashboards";
            };
          }
        ];
      };
    };
  };

  # Create dashboard directory and add some useful dashboards
  systemd.tmpfiles.rules = [
    "d /var/lib/grafana/dashboards 0755 grafana grafana -"
  ];

  # Download and provision some useful dashboards
  environment.etc = {
    # Node Exporter Full Dashboard
    "grafana-dashboards/node-exporter.json" = {
      source = pkgs.fetchurl {
        url = "https://grafana.com/api/dashboards/1860/revisions/37/download";
        sha256 = "sha256-PLACEHOLDER"; # Replace with actual hash after first run
      };
      target = "/var/lib/grafana/dashboards/node-exporter.json";
      user = "grafana";
      group = "grafana";
    };
    "grafana-dashboards/system-overview.json" = {
      text = builtins.toJSON {
        dashboard = {
          title = "System Overview";
          uid = "system-overview";
          timezone = "browser";
          panels = [
            {
              id = 1;
              type = "graph";
              title = "CPU Usage";
              targets = [
                {
                  expr = ''100 - (avg(rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)'';
                  refId = "A";
                  datasource = {
                    type = "prometheus";
                    uid = "prometheus-uid";
                  };
                }
              ];
              gridPos = {
                h = 8;
                w = 12;
                x = 0;
                y = 0;
              };
            }
            {
              id = 2;
              type = "graph";
              title = "Memory Usage";
              targets = [
                {
                  expr = ''(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100'';
                  refId = "A";
                  datasource = {
                    type = "prometheus";
                    uid = "prometheus-uid";
                  };
                }
              ];
              gridPos = {
                h = 8;
                w = 12;
                x = 12;
                y = 0;
              };
            }
            {
              id = 3;
              type = "graph";
              title = "Disk Usage";
              targets = [
                {
                  expr = ''100 - (node_filesystem_avail_bytes{fstype!~"tmpfs|fuse.lxcfs|squashfs|vfat"} / node_filesystem_size_bytes{fstype!~"tmpfs|fuse.lxcfs|squashfs|vfat"}) * 100'';
                  refId = "A";
                  datasource = {
                    type = "prometheus";
                    uid = "prometheus-uid";
                  };
                }
              ];
              gridPos = {
                h = 8;
                w = 12;
                x = 0;
                y = 8;
              };
            }
            {
              id = 4;
              type = "graph";
              title = "Network Traffic";
              targets = [
                {
                  expr = ''rate(node_network_receive_bytes_total[5m])'';
                  legendFormat = "RX {{device}}";
                  refId = "A";
                  datasource = {
                    type = "prometheus";
                    uid = "prometheus-uid";
                  };
                }
                {
                  expr = ''rate(node_network_transmit_bytes_total[5m])'';
                  legendFormat = "TX {{device}}";
                  refId = "B";
                  datasource = {
                    type = "prometheus";
                    uid = "prometheus-uid";
                  };
                }
              ];
              gridPos = {
                h = 8;
                w = 12;
                x = 12;
                y = 8;
              };
            }
          ];
          schemaVersion = 39;
          version = 1;
        };
      };
      target = "/var/lib/grafana/dashboards/system-overview.json";
      user = "grafana";
      group = "grafana";
    };
  };
}
