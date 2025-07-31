{
  config,
  lib,
  ...
}:
let
  inherit (config.sharedVariables) domain;
in
{
  sops.secrets = {
    # Origin Certificate (+ Private key)
    cloudflared_ilak_ch_pem = {
      key = "cloudflared/ilak_ch_pem";
      owner = "caddy";
      group = "caddy";
      mode = "0440";
    };
    cloudflared_ilak_ch_private_key = {
      key = "cloudflared/ilak_ch_private_key";
      owner = "caddy";
      group = "caddy";
      mode = "0440";
    };
  };

  sops.templates."mtls_combined.pem" =
    let
      combinedCert = lib.concatStrings [
        "${config.sops.placeholder.cloudflared_ilak_ch_pem}"
        "${config.sops.placeholder.cloudflare_authenticated_origin_pull_ca}"
      ];
    in
    {
      content = "${combinedCert}";
      owner = "caddy";
    };

  services.caddy =
    let
      autheliaPort = builtins.toString config.sharedVariables.authelia.port;
      secureConfig = ''
        forward_auth * https://auth.${domain} {
            uri /api/authz/forward-auth
            copy_headers Remote-User Remote-Groups Remote-Name Remote-Email X-Forwarded-Proto X-Forwarded-Host X-Forwarded-URI X-Forwarded-For
            header_up Host {upstream_hostport}
          }
      '';
    in
    {
      enable = true;
      globalConfig = ''
        auto_https off
      '';
      virtualHosts =
        let
          originPem = config.sops.secrets.cloudflared_ilak_ch_pem.path;
          originPrivateKey = config.sops.secrets.cloudflared_ilak_ch_private_key.path;
          # trustedCaCert = config.sops.secrets.cloudflare_authenticated_origin_pull_ca.path;

          homepagePort = builtins.toString config.services.homepage-dashboard.listenPort;
        in
        {
          "auth.${domain}" = {
            extraConfig = ''
              tls ${originPem} ${originPrivateKey} 
              #{
              #  client_auth {
              #    mode require_and_verify
              #    trusted_ca_cert_file ${config.sops.templates."mtls_combined.pem".path}
              #  }
              #}
              reverse_proxy 127.0.0.1:${autheliaPort}
            '';
          };

          "home.${domain}" = {
            extraConfig = ''
              tls ${originPem} ${originPrivateKey}
              ${secureConfig}
              reverse_proxy 127.0.0.1:${homepagePort}
            '';
          };
        };
    };
}
