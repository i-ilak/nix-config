{
  config,
  ...
}:
let
  inherit (config.sharedVariables) domain;
in
{
  sops.secrets = {
    cloudflared_origin_cert_pem = {
      key = "cloudflared/origin_cert_pem";
      owner = "caddy";
      group = "caddy";
      mode = "0440";
    };
    cloudflared_origin_cert_private_key = {
      key = "cloudflared/origin_cert_private_key";
      owner = "caddy";
      group = "caddy";
      mode = "0440";
    };
  };

  services.caddy = {
    enable = true;
    globalConfig = ''
      auto_https off
      debug
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
            reverse_proxy 127.0.0.1:${homepagePort}
          '';
        };
      };
  };
}
