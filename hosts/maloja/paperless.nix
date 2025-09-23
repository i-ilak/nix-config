{
  config,
  pkgs,
  inputs,
  ...
}:
let
  inherit (config.sharedVariables) publicDomain;
  inherit (config.sharedVariables.paperless) backupDir;

  baseDirPaperless = "/var/lib/paperless";
  mediaDir = "${baseDirPaperless}/media";
  dataDir = "${baseDirPaperless}/data";
in
{
  sops = {
    secrets = {
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
      paperless_admin_password = {
        key = "paperless/admin_password";
        owner = "paperless";
        group = "paperless";
        mode = "0440";
      };
    };
    templates = {
      "paperless-repositoryFile" = {
        content = ''
          s3:${config.sops.placeholder."paperless-b2-endpoint"}/${
            config.sops.placeholder."paperless-b2-bucket_name"
          }
        '';
        owner = "root";
        group = "backup";
        mode = "0440";
      };
      "paperless-accessFile" = {
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

  # sops.templates.paperless_environment_file = {
  #   content = ''
  #     PAPERLESS_APPS=allauth.socialaccount.providers.openid_connect
  #     PAPERLESS_SOCIALACCOUNT_PROVIDERS={"openid_connect":{"SCOPE":["openid","profile","email"],"OAUTH_PKCE_ENABLED":true,"APPS":[{"provider_id":"authelia","name":"Authelia","client_id":"paperless","secret":"insecure_secret","settings":{"server_url":"https://auth.${publicDomain}","token_auth_method":"client_secret_basic"}}]}}
  #   '';
  #   owner = "paperless";
  #   group = "paperless";
  #   mode = "0440";
  # };

  services.paperless = {
    enable = true;
    package = inputs.paperless-ngx.legacyPackages."x86_64-linux".paperless-ngx;
    address = "127.0.0.1";
    settings = {
      PAPERLESS_OCR_LANGUAGE = "deu+eng";
      PAPERLESS_URL = "https://paperless.${publicDomain}";
      PAPERLESS_TRUSTED_PROXIES = "127.0.0.1";
      PAPERLESS_USE_X_FORWARD_HOST = true;
      PAPERLESS_USE_X_FORWARD_PORT = true;
      PAPERLESS_PROXY_SSL_HEADER = ''["HTTP_X_FORWARDED_PROTO", "https"]'';
      PAPERLESS_ENABLE_NLTK = false;
    };
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

  services.restic.backups.paperless = {
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

    environmentFile = config.sops.templates."paperless-accessFile".path;
    repositoryFile = config.sops.templates."paperless-repositoryFile".path;
    passwordFile = config.sops.secrets."restic-password-file".path;
  };

  systemd.services.paperless-restore-from-backup = {
    description = "Restore Paperless-NGX from S3 backup if not already done";

    wantedBy = [ "multi-user.target" ];
    wants = [
      "network-online.target"
      "var-lib-paperless.mount"
    ];
    after = [
      "network-online.target"
      "unbound.service"
      "adguardhome.service"
    ];
    before = [
      "paperless-web.service"
      "paperless-exporter.service"
      "paperless-consumer.service"
      "paperless-scheduler.service"
      "paperless-task-queue.service"
    ];
    unitConfig = {
      ConditionPathExists = "!${baseDirPaperless}/.restore_service_completed";
    };

    serviceConfig = {
      Type = "oneshot";
      User = "root";
      Group = "backup";
      EnvironmentFile = config.sops.templates."paperless-accessFile".path;
      WorkingDirectory = "${dataDir}";
    };

    script =
      # bash
      ''
        RESTORE_COMPLETION_FLAG="${baseDirPaperless}/.restore_service_completed"

        if [ -f "$RESTORE_COMPLETION_FLAG" ]; then
          echo "Restore completion flag found ($RESTORE_COMPLETION_FLAG). Skipping restore."
          exit 0
        fi

        echo "--- Starting Paperless-NGX restore from S3 backup ---"

        echo "Restoring latest backup to ${backupDir}..."
        ${pkgs.restic}/bin/restic                                                           \
          --repository-file "${config.sops.templates."paperless-repositoryFile".path}"      \
          --password-file "${config.sops.secrets."restic-password-file".path}"              \
          restore latest:${backupDir} --target ${backupDir}

        chown -R paperless:paperless "${backupDir}"

        echo "Importing documents into Paperless-NGX..."
        ${pkgs.su}/bin/su -s ${pkgs.bash}/bin/bash paperless -c "
          export PAPERLESS_DATA_DIR=${dataDir}
          export PAPERLESS_MEDIA_ROOT=${mediaDir}
          export PAPERLESS_CONSUMPTION_DIR=${dataDir}/consume
          paperless-manage migrate
          paperless-manage document_importer '${backupDir}'
        "

        echo "Cleaning up temporary directory..."
        rm -rf "$RESTORE_DIR"

        echo "Creating restore completion flag file: $RESTORE_COMPLETION_FLAG."
        touch "$RESTORE_COMPLETION_FLAG"
        chown "${config.services.paperless.user}:paperless" "$RESTORE_COMPLETION_FLAG"
        echo "--- Paperless-NGX restore complete ---"
      '';
  };
}
