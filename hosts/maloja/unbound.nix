{
  config,
  pkgs,
  ...
}:
{
  services.resolved.enable = false;

  services.unbound = {
    enable = true;
    settings = {
      server = {
        inherit (config.sharedVariables.unbound) port;
        interface = [ "127.0.0.1" ];
        access-control = [
          "0.0.0.0/0 refuse"
          "127.0.0.1 allow"
          "::0/0 refuse"
          "::1 allow"
        ];

        harden-glue = true;
        harden-dnssec-stripped = true;
        use-caps-for-id = false;
        prefetch = true;
        edns-buffer-size = 1232;

        # Custom settings
        hide-identity = true;
        hide-version = true;

        root-hints = "${pkgs.dns-root-data}/root.hints";
      };
    };
  };
}
