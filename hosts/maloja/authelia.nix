{
  inputs,
  config,
  ...
}:
let
  authelia_user_conf_path = "/var/lib/authelia-main/users_database.yml";
in
{
  sops.secrets = {
    authelia_storage_encryption_key = {
      key = "authelia/storage_encryption_key";
      owner = "authelia-main";
      group = "authelia-main";
      mode = "0440";
    };
    authelia_jwt_secret = {
      key = "authelia/jwt_secret";
      owner = "authelia-main";
      group = "authelia-main";
      mode = "0440";
    };
    authelia_session_secret = {
      key = "authelia/session_secret";
      owner = "authelia-main";
      group = "authelia-main";
      mode = "0440";
    };
    authalia_user_conf = {
      sopsFile = "${inputs.nix-secrets}/secrets/maloja/authelia_users";
      format = "binary";
      path = authelia_user_conf_path;
      owner = "authelia-main";
      group = "authelia-main";
      mode = "0400";
    };
  };

  services.authelia.instances =
    let
      inherit (config.sharedVariables) baseDomain;
      autheliaPort = config.sharedVariables.authelia.port;
    in
    {
      main = {
        enable = true;
        secrets = {
          storageEncryptionKeyFile = config.sops.secrets.authelia_storage_encryption_key.path;
          jwtSecretFile = config.sops.secrets.authelia_jwt_secret.path;
          sessionSecretFile = config.sops.secrets.authelia_session_secret.path;
          manual = false;
        };

        settings = {
          theme = "dark";
          default_2fa_method = "totp";
          server.address = "tcp://127.0.0.1:${builtins.toString autheliaPort}/";
          log.level = "info";
          session = {
            name = "authelia_session";
            domain = "auth.${baseDomain}";
            expiration = "1h";
            inactivity = "15m";
          };
          authentication_backend = {
            file = {
              path = authelia_user_conf_path;
              watch = false;
            };
          };
          regulation = {
            max_retries = 3;
            find_time = "5m";
            ban_time = "30m";
          };
          access_control = {
            default_policy = "deny"; # Secure by default
            rules = [
              {
                domain = "auth.${baseDomain}"; # Your Authelia portal URL
                policy = "bypass";
              }
              {
                domain = "home.${baseDomain}";
                policy = "one_factor";
                subject = [ "group:users" ];
              }
              {
                domain = "admin.${baseDomain}";
                policy = "two_factor";
                subject = [ "group:admins" ];
              }
            ];
          };
          storage = {
            local = {
              path = "/var/lib/authelia-main/db.sqlite3";
            };
          };
          notifier = {
            filesystem = {
              filename = "/var/lib/authelia-main/notification.txt";
            };
          };
        };
      };
    };
}
