{
  config,
  ...
}:
{
  services.caddy =
    let
      certloc = "${config.security.acme.certs."${config.sharedVariables.domain}".directory}";
    in
    {
      enable = true;
      group = "caddy";
      globalConfig = ''
        {
          admin off
          auto_https off # security.acme provides the certificates
        }
      '';
      virtualHosts."${config.sharedVariables.domain}" = {
        listenAddresses = [ "127.0.0.1:8080" ]; # No binding to LAN!
        extraConfig = ''
          reverse_proxy 127.0.0.1:${toString config.services.vaultwarden.config.ROCKET_PORT} {
            header_up Host {host}
            header_up X-Real-IP {remote_ip}
            header_up X-Forwarded-For {remote_ip}
            header_up X-Forwarded-Proto {scheme}
          }

          # Re-enable TLS for the internal connection to cloudflared
          tls ${certloc}/cert.pem ${certloc}/key.pem {
            protocols tls1.3
            # Enable client authentication (mTLS)
            client_auth {
              mode require
              trusted_ca_certs ${config.sops.secrets.cloudflared_origin_pulls_ca_cert.path}
            }
          }
        '';
      };
    };

  systemd.services.caddy.unitConfig = {
    Requires = [ "vaultwarden.service" ];
    After = [ "vaultwarden.service" ];
    BindsTo = [ "vaultwarden.service" ];
  };
}
