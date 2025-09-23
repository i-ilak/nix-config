{
  config,
  pkgs,
  ...
}:
{
  sops = {
    secrets = {
      home-assistant-b2-endpoint = {
        key = "home-assistant/b2/endpoint";
        owner = "root";
        group = "backup";
        mode = "0440";
      };
      home-assistant-b2-bucket_name = {
        key = "home-assistant/b2/bucket_name";
        owner = "root";
        group = "backup";
        mode = "0440";
      };
      home-assistant-b2-account_id = {
        key = "home-assistant/b2/account_id";
        owner = "root";
        group = "backup";
        mode = "0440";
      };
      home-assistant-b2-application_key = {
        key = "home-assistant/b2/application_key";
        owner = "root";
        group = "backup";
        mode = "0440";
      };
    };
    templates = {
      "home-assistant-repositoryFile" = {
        content = ''
          s3:${config.sops.placeholder."home-assistant-b2-endpoint"}/${
            config.sops.placeholder."home-assistant-b2-bucket_name"
          }
        '';
        owner = "root";
        group = "backup";
        mode = "0440";
      };
      "home-assistant-accessFile" = {
        content = ''
          AWS_ACCESS_KEY_ID="${config.sops.placeholder."home-assistant-b2-account_id"}"
          AWS_SECRET_ACCESS_KEY="${config.sops.placeholder."home-assistant-b2-application_key"}"
        '';
        owner = "root";
        group = "backup";
        mode = "0440";
      };
    };
  };

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
      http = {
        server_port = config.sharedVariables.home-assistant.port;
        use_x_forwarded_for = true;
        trusted_proxies = [ "127.0.0.1" ];
      };
    };
  };

  services.restic.backups.home-assistant = {
    initialize = true;
    paths = [
      config.sharedVariables.home-assistant.backupDir
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

    environmentFile = config.sops.templates."home-assistant-accessFile".path;
    repositoryFile = config.sops.templates."home-assistant-repositoryFile".path;
    passwordFile = config.sops.secrets."restic-password-file".path;
  };

  systemd.services.home-assistant-restore-from-backup =
    let
      baseDirHomeAssistant = "/var/lib/hass";
      backupDir = "${baseDirHomeAssistant}/backups";
    in
    {
      description = "Restore Home Assistant from S3 backup if not already done";

      wantedBy = [ "multi-user.target" ];
      wants = [
        "network-online.target"
        "var-lib-hass.mount"
      ];
      after = [
        "network-online.target"
        "unbound.service"
        "adguardhome.service"
      ];
      before = [
        "home-assistant.service"
      ];
      unitConfig = {
        ConditionPathExists = "!${baseDirHomeAssistant}/.restore_service_completed";
      };

      serviceConfig = {
        Type = "oneshot";
        User = "root";
        Group = "backup";
        EnvironmentFile = config.sops.templates."home-assistant-accessFile".path;
        WorkingDirectory = "${baseDirHomeAssistant}";
      };

      script =
        # bash
        ''
          RESTORE_COMPLETION_FLAG="${baseDirHomeAssistant}/.restore_service_completed"

          if [ -f "$RESTORE_COMPLETION_FLAG" ]; then
            echo "Restore completion flag found ($RESTORE_COMPLETION_FLAG). Skipping restore."
            exit 0
          fi

          echo "--- Starting Home Assistant restore from S3 backup ---"

          echo "Restoring latest backup to ${backupDir}..."
          ${pkgs.restic}/bin/restic                                                             \
              --repository-file "${config.sops.templates."home-assistant-repositoryFile".path}"           \
              --password-file "${config.sops.secrets."restic-password-file".path}"              \
              restore latest:${backupDir} --target ${backupDir}
            
          chown -R hass:hass "${backupDir}"

          NEWEST_SLUG=$(ha --config ${baseDirHomeAssistant}/configuration.yaml backups list | grep -v "SLUG" | head -1 | awk '{print $1}')
          echo "The newst slug is: $NEWEST_SLUG"
          echo "Importing data into Home Assistant..."
          ha --config ${baseDirHomeAssistant}/configuration.yaml backups restore $NEWEST_SLUG


          echo "Creating restore completion flag file: $RESTORE_COMPLETION_FLAG."
          touch "$RESTORE_COMPLETION_FLAG"
          chown hass:hass "$RESTORE_COMPLETION_FLAG"
          echo "--- Home Assistant restore complete ---"
        '';
    };
}
