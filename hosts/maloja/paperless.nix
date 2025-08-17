{
  config,
  ...
}:
let
  inherit (config.sharedVariables) baseDomain;
in
{
  sops.secrets = {
    paperless_admin_password = {
      key = "paperless/admin_password";
      owner = "paperless";
      mode = "0400";
    };
  };

  sops.templates.paperless_environment_file = {
    content = ''
      PAPERLESS_APPS=allauth.socialaccount.providers.openid_connect
      PAPERLESS_SOCIALACCOUNT_PROVIDERS={"openid_connect":{"SCOPE":["openid","profile","email"],"OAUTH_PKCE_ENABLED":true,"APPS":[{"provider_id":"authelia","name":"Authelia","client_id":"paperless","secret":"insecure_secret","settings":{"server_url":"https://auth.${baseDomain}","token_auth_method":"client_secret_basic"}}]}}
    '';
  };
  systemd.user.tmpfiles.rules = [
    ''
      d /tmp/paperless  0755 paperless users -
    ''
  ];
  services.paperless = {
    enable = true;
    address = "0.0.0.0";
    port = 58080;
    extraConfig.PAPERLESS_OCR_LANGUAGE = "deu+eng";
  };
  systemd.services.paperless-scheduler.after = [ "var-lib-paperless.mount" ];
  systemd.services.paperless-consumer.after = [ "var-lib-paperless.mount" ];
  systemd.services.paperless-web.after = [ "var-lib-paperless.mount" ];

  # services.paperless = {
  #   enable = true;
  #   passwordFile = config.sops.secrets.paperless_admin_password.path;
  #   # environmentFile = config.sops.templates.paperless_environment_file.path;
  #
  #   exporter = {
  #     enable = true;
  #     directory = config.sharedVariables.paperless.backupDir;
  #   };
  #
  #   inherit (config.sharedVariables.paperless) port;
  #   inherit (config.sharedVariables.paperless) mediaDir;
  #   inherit (config.sharedVariables.paperless) dataDir;
  # };
}
