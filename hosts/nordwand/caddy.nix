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
      virtualHosts."${config.sharedVariables.domain}" = {
        # Caddy will bind to 0.0.0.0:80 and 0.0.0.0:443 for public access
        # including ACME challenges.
        extraConfig = ''
          reverse_proxy 127.0.0.1:${toString config.services.vaultwarden.config.ROCKET_PORT} {
            header_up Host {host}
            header_up X-Real-IP {remote_ip}
            header_up X-Forwarded-For {remote_ip}
            header_up X-Forwarded-Proto {scheme}
          }

          tls ${certloc}/cert.pem ${certloc}/key.pem {
            protocols tls1.3
          }
        '';
      };
    };

  systemd.services.caddy.unitConfig = {
    After = [ "vaultwarden.service" ];
  };
}
