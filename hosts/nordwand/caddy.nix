{
  config,
  ...
}:
let
  inherit (config.sharedVariables) domain;
in
{
  services.caddy = {
    enable = true;

    globalConfig = ''
      auto_https off
    '';

    virtualHosts =
      let
        originPem = config.sops.secrets.cloudflared_origin_cert_pem.path;
        originPrivateKey = config.sops.secrets.cloudflared_origin_cert_private_key.path;
        trustedCaCert = config.sops.secrets.cloudflare_authenticated_origin_pull_ca.path;

        autheliaPort = builtins.toString config.sharedVariables.authelia.port;
        homepagePort = builtins.toString config.services.homepage-dashboard.listenPort;
      in
      {
        "auth.${domain}" = {
          extraConfig = ''
            tls ${originPem} ${originPrivateKey} {
              client_auth {
                mode require_and_verify
                trusted_ca_cert_file ${trustedCaCert}
              }
            }

            reverse_proxy 127.0.0.1:${autheliaPort}
          '';
        };

        "home.${domain}" = {
          extraConfig = ''
            tls ${originPem} ${originPrivateKey} {
              client_auth {
                mode require_and_verify
                trusted_ca_cert_file ${trustedCaCert}
              }
            }

            forward_auth 127.0.0.1:${autheliaPort} {
              uri /api/authz/forward-auth
              copy_headers Remote-User Remote-Groups Remote-Name Remote-Email
              header_up Host {upstream_hostport}
            }
            reverse_proxy 127.0.0.1:${homepagePort}
          '';
        };
      };
  };
}
