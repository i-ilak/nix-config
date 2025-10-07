{
  config,
  inputs,
  pkgs,
  ...
}:
let
  inherit (config.networkLevelVariables) publicDomain;
in
{
  services.caddy =
    let
      inherit (config.sharedVariables) hostName;

      certloc = "/var/lib/acme/${publicDomain}";
      commonConfig = ''
        bind ${config.networkLevelVariables.ipMap.${hostName}}
        tls ${certloc}/cert.pem ${certloc}/key.pem {
          protocols tls1.3
        }
      '';
    in
    {
      enable = true;
      package = inputs.nixpkgs-unstable.legacyPackages."x86_64-linux".caddy;
      virtualHosts = {
        "jellyfin.${publicDomain}" = {
          extraConfig = ''
            ${commonConfig}
            reverse_proxy 127.0.0.1:8096
          '';
        };
        "home.${publicDomain}" = {
          extraConfig = ''
            ${commonConfig}
            reverse_proxy 127.0.0.1:${toString config.sharedVariables."home-assistant".port}
          '';
        };
        "paperless.${publicDomain}" = {
          extraConfig = ''
            ${commonConfig}
            reverse_proxy 127.0.0.1:${toString config.sharedVariables.paperless.port} {
              header_up Host {host}
              header_up X-Real-IP {remote_host}
              header_down Referrer-Policy "strict-origin-when-cross-origin"
            }
            encode {
              zstd
              gzip
              minimum_length 1024
            }
          '';
          logFormat = ''
            format console
            output file /var/log/caddy/access-${hostName}.log {
              roll_size 10mb
              roll_keep 20
              roll_keep_for 7d
            }
          '';
        };
        "cache.nixos.${publicDomain}" = {
          extraConfig = ''
            ${commonConfig}
            reverse_proxy 127.0.0.1:${toString config.sharedVariables.atticd.port}
          '';
        };
      };
    };

  systemd = {
    paths."reload-caddy-on-cert-change" = {
      description = "Watch ACME certs and trigger caddy reload on changes";
      wantedBy = [ "multi-user.target" ];
      pathConfig = {
        PathChanged = "/var/lib/acme/${publicDomain}";
      };
    };
    services = {
      caddy = {
        after = [ "acme-${publicDomain}.service" ];
        requires = [ "acme-${publicDomain}.service" ];
      };
      "reload-caddy-on-cert-change" = {
        description = "Reload caddy when ACME certs change";
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.systemd}/bin/systemctl reload caddy.service";
        };
      };
    };
  };
}
