{
  config,
  inputs,
  ...
}:
{
  services.caddy =
    let
      inherit (config.sharedVariables) baseDomain;
      inherit (config.sharedVariables) hostname;
      inherit (config.sharedVariables) ip;

      commonConfig = ''
        bind ${ip}
        tls internal
      '';
    in
    {
      enable = true;
      package = inputs.nixpkgs-unstable.legacyPackages."x86_64-linux".caddy;
      virtualHosts = {
        "jellyfin.${baseDomain}" = {
          extraConfig = ''
            ${commonConfig}
            reverse_proxy 127.0.0.1:8096
          '';
        };
        "home.${baseDomain}" = {
          extraConfig = ''
            ${commonConfig}
            reverse_proxy 127.0.0.1:${toString config.sharedVariables."home-assistant".port}
          '';
        };
        "paperless.${baseDomain}" = {
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
            output file /var/log/caddy/access-${hostname}.log {
              roll_size 10mb
              roll_keep 20
              roll_keep_for 7d
            }
          '';
        };
        "adguard.${baseDomain}" = {
          extraConfig = ''
            ${commonConfig}
            reverse_proxy 127.0.0.1:${toString config.sharedVariables.adguardhome.port}
          '';
        };
      };
    };
}
