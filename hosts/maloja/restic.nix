{
  config,
  ...
}:
{
  sops = {
    secrets = {
      restic-password-file = {
        key = "restic/password_file";
        owner = "root";
        group = "backup";
        mode = "0440";
      };
      paperless-b2-endpoint = {
        key = "paperless/b2/endpoint";
        owner = "root";
        group = "backup";
        mode = "0440";
      };
      paperless-b2-bucket_name = {
        key = "paperless/b2/bucket_name";
        owner = "root";
        group = "backup";
        mode = "0440";
      };
      paperless-b2-account_id = {
        key = "paperless/b2/account_id";
        owner = "root";
        group = "backup";
        mode = "0440";
      };
      paperless-b2-application_key = {
        key = "paperless/b2/application_key";
        owner = "root";
        group = "backup";
        mode = "0440";
      };
    };
    templates = {
      "repositoryFile" = {
        content = ''
          s3:${config.sops.placeholder."paperless-b2-endpoint"}/${
            config.sops.placeholder."paperless-b2-bucket_name"
          }
        '';
        owner = "root";
        group = "backup";
        mode = "0440";
      };
      "accessFile" = {
        content = ''
          AWS_ACCESS_KEY_ID="${config.sops.placeholder."paperless-b2-account_id"}"
          AWS_SECRET_ACCESS_KEY="${config.sops.placeholder."paperless-b2-application_key"}"
        '';
        owner = "root";
        group = "backup";
        mode = "0440";
      };
    };
  };

  services.restic = {
    backups = {
      paperless = {
        initialize = true;
        paths = [
          config.sharedVariables.paperless.backupDir
        ];
        pruneOpts = [
          "--keep-daily 7"
          "--keep-weekly 5"
          "--keep-monthly 12"
          "--keep-yearly 10"
        ];
        timerConfig = {
          OnCalendar = "daily";
          Persistent = true;
        };

        environmentFile = config.sops.templates."accessFile".path;
        repositoryFile = config.sops.templates."repositoryFile".path;
        passwordFile = config.sops.secrets."restic-password-file".path;
      };
    };

  };
}
