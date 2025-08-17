{
  config,
  ...
}:
let
  inherit (config.sharedVariables) baseDomain;
  baseDirPaperless = "/var/lib/paperless";
  mediaDir = "${baseDirPaperless}/media";
  dataDir = "${baseDirPaperless}/data";
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

  services.paperless = {
    enable = true;
    address = "0.0.0.0";

    settings.PAPERLESS_OCR_LANGUAGE = "deu+eng";
    passwordFile = config.sops.secrets.paperless_admin_password.path;
    exporter = {
      enable = true;
      directory = config.sharedVariables.paperless.backupDir;
    };

    inherit mediaDir;
    inherit dataDir;
    inherit (config.sharedVariables.paperless) port;
  };
  systemd.services = {
    paperless-scheduler.after = [ "var-lib-paperless.mount" ];
    paperless-consumer.after = [ "var-lib-paperless.mount" ];
    paperless-web.after = [ "var-lib-paperless.mount" ];
  };
}
