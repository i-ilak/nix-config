{
  config,
  ...
}:
{
  services.caddy = {
    enable = true;

    virtualHosts = {
      "jellyfin.maloja.local" = {
        extraConfig = ''
          bind ${config.sharedVariables.ip} 127.0.0.1
          reverse_proxy localhost:8096
        '';
      };

      "homeassistant.maloja.local" = {
        extraConfig = ''
          bind ${config.sharedVariables.ip} 127.0.0.1
          reverse_proxy localhost:${toString config.sharedVariables.home-assistant.port}
        '';
      };

      "paperless.maloja.local" = {
        extraConfig = ''
          bind ${config.sharedVariables.ip} 127.0.0.1
          reverse_proxy localhost:${toString config.sharedVariables.paperless.port}
        '';
      };

      "authelia.maloja.local" = {
        extraConfig = ''
          bind ${config.sharedVariables.ip} 127.0.0.1
          tls internal
          reverse_proxy localhost:${toString config.sharedVariables.authelia.port}
        '';
      };
    };
  };
}
