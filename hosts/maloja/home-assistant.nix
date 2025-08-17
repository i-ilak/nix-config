{
  config,
  ...
}:
{
  services.home-assistant = {
    enable = true;
    extraComponents = [
      "esphome"
      "homekit_controller"
      "apple_tv"
      "met"
      "radio_browser"
      "google_translate"
      "vesync"
      "hue"
    ];
    config = {
      # Includes dependencies for a basic setup
      # https://www.home-assistant.io/integrations/default_config/
      default_config = { };
      http.server_port = config.sharedVariables.home-assistant.port;
    };
  };
}
