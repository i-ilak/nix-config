{
  config,
  inputs,
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
      package = inputs.nixpkgs-unstable.legacyPackages."aarch64-linux".caddy;
      virtualHosts = {
        "network.${publicDomain}" = {
          extraConfig = ''
            ${commonConfig}
            reverse_proxy https://127.0.0.1:8443 {
              transport http {
                tls_insecure_skip_verify
              }
            }
          '';
        };
        "adguard.${publicDomain}" = {
          extraConfig = ''
            ${commonConfig}
            reverse_proxy 127.0.0.1:${toString config.sharedVariables.adguardhome.port}
          '';
        };
      };
    };

  systemd.services.caddy.requires = [ "acme-certs-sync.service" ];
}
