{
  config,
  pkgs,
  ...
}:
let
  inherit (config.sharedVariables) baseDomain;
  inherit (config.sharedVariables.paperless) backupDir;

  baseDirPaperless = "/var/lib/paperless";
  mediaDir = "${baseDirPaperless}/media";
  dataDir = "${baseDirPaperless}/data";
in
{
  sops.secrets = {
    paperless_admin_password = {
      key = "paperless/admin_password";
      owner = "paperless";
      group = "paperless";
      mode = "0440";
    };
  };

  sops.templates.paperless_environment_file = {
    content = ''
      PAPERLESS_APPS=allauth.socialaccount.providers.openid_connect
      PAPERLESS_SOCIALACCOUNT_PROVIDERS={"openid_connect":{"SCOPE":["openid","profile","email"],"OAUTH_PKCE_ENABLED":true,"APPS":[{"provider_id":"authelia","name":"Authelia","client_id":"paperless","secret":"insecure_secret","settings":{"server_url":"https://auth.${baseDomain}","token_auth_method":"client_secret_basic"}}]}}
    '';
    owner = "paperless";
    group = "paperless";
    mode = "0440";
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

  systemd.services.paperless-restore-from-backup = {
    description = "Restore Paperless-NGX from S3 backup if not already done";

    wantedBy = [ "multi-user.target" ];
    wants = [
      "network-online.target"
      "var-lib-paperless.mount"
    ];
    after = [
      "network-online.target"
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
      EnvironmentFile = config.sops.templates."accessFile".path;
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
        ${pkgs.restic}/bin/restic                                               \
          --repository-file "${config.sops.templates."repositoryFile".path}"    \
          --password-file "${config.sops.secrets."restic-password-file".path}"  \
          restore latest:${backupDir} --target ${backupDir}

        chown -R paperless:paperless "${backupDir}"

        echo "Importing documents into Paperless-NGX..."
        ${pkgs.su}/bin/su -s /bin/sh paperless -c "
          export PAPERLESS_DATA_DIR=${dataDir} 
          export PAPERLESS_MEDIA_ROOT=${mediaDir} 
          export PAPERLESS_CONSUMPTION_DIR=${dataDir}/consume 
          ${pkgs.paperless-ngx}/bin/paperless-ngx migrate
          ${pkgs.paperless-ngx}/bin/paperless-ngx document_importer '${backupDir}'
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
