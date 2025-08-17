{
  config,
  ...
}:
{
  services.caddy =
    let
      inherit (config.sharedVariables) baseDomain;
    in
    {
      enable = true;
      globalConfig = ''
        skip_install_trust
      '';
      virtualHosts = {
        "jellyfin.${baseDomain}" = {
          extraConfig = ''
            bind ${config.sharedVariables.ip}
            tls internal
            reverse_proxy 127.0.0.1:8096
          '';
        };
        "home.${baseDomain}" = {
          extraConfig = ''
            bind ${config.sharedVariables.ip}
            tls internal
            reverse_proxy 127.0.0.1:${toString config.sharedVariables."home-assistant".port}
          '';
        };
        "paperless.${baseDomain}" = {
          extraConfig = ''
            bind ${config.sharedVariables.ip}
            tls internal
            reverse_proxy 127.0.0.1:${toString config.sharedVariables.paperless.port}
          '';
        };
        "auth.${baseDomain}" = {
          extraConfig = ''
            bind ${config.sharedVariables.ip}
            tls internal
            reverse_proxy 127.0.0.1:${toString config.sharedVariables.authelia.port}
          '';
        };
      };
    };
}
