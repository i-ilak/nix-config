{
  config,
  ...
}:
{
  # sops.secrets.vaultwarden_admin_token = {
  #   key = "vaultwarden/admin_token";
  #   # nix-shell -p vaultwarden --run "vaultwarden hash"
  #   owner = "vaultwarden";
  #   group = "vaultwarden";
  #   mode = "0400";
  # };

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
      ROCKET_ENV = "production";
      ROCKET_WORKERS = 10;
      ADMIN_RATELIMIT_SECONDS = 300;
      ADMIN_RATELIMIT_MAX_BURST = 3;
    };
  };
}
