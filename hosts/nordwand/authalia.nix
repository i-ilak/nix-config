{
  config,
  ...
}:
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

  };
  services.authelia.instances = {
    main =
      let
        inherit (config.sharedVariables) domain;
      in
      {
        enable = true;
        secrets = {
          storageEncryptionKeyFile = config.sops.secrets.authelia_storage_encryption_key.path;
          jwtSecretFile = config.sops.secrets.authelia_jwt_secret.path;
          manual = false;
        };

        settings = {
          theme = "light";
          default_2fa_method = "totp";

          server.address = "tcp://127.0.0.1:${builtins.toString config.sharedVariables.authelia.port}/";

          log = {
            level = "info";
          };

          session = {
            name = "authelia_session";
            domain = "${domain}";
            expiration = "12h";
            inactivity = "45m";
          };

          authentication_backend = {
            file = {
              path = "/var/lib/authelia-main/users_database.yml";
            };
          };

          access_control = {
            default_policy = "deny";
            rules = [
              {
                domain = "auth.${domain}";
                policy = "bypass";
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
