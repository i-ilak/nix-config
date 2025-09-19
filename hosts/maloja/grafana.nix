{
  config,
  ...
}:
{
  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_port = config.sharedVariables.grafana.port;
        # If using Caddy, you can set this to your domain
        # root_url = "https://grafana.yourdomain.com";
      };
    };
  };
}
