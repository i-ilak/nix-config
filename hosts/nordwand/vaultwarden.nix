{
  config,
  ...
}:
{
  services.vaultwarden = {
    enable = true;
    dbBackend = "sqlite";
    config = {
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 8000;
      DOMAIN = "https://${config.sharedVariables.domain}";
      SIGNUPS_ALLOWED = false;
      WEBSOCKET_ENABLED = true;
      ADMIN_TOKEN = config.sops.secrets.vaultwarden_admin_token.path;
      LOG_LEVEL = "info";
    };
  };

  systemd.services.vaultwarden.unitConfig = {
    After = [ "tailscale.service" ];
  };
}
