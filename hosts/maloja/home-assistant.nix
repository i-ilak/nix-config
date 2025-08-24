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
      http = {
        server_port = config.sharedVariables.home-assistant.port;
        use_x_forwarded_for = true;
        trusted_proxies = [ "127.0.0.1" ];
      };
    };
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
          restic-home-assistant restore latest:${backupDir} --target ${backupDir}
            
          chown -R "${config.services.home-assistant.user}:${config.services.home-assistant.group}" "${backupDir}"

          NEWEST_SLUG=$(ha --config ${baseDirHomeAssistant}/configuration.yaml backups list | grep -v "SLUG" | head -1 | awk '{print $1}')
          echo "The newst slug is: $NEWEST_SLUG"
          echo "Importing data into Home Assistant..."
          ha --config ${baseDirHomeAssistant}/configuration.yaml backups restore $NEWEST_SLUG


          echo "Creating restore completion flag file: $RESTORE_COMPLETION_FLAG."
          touch "$RESTORE_COMPLETION_FLAG"
          chown "${config.services.home-assistant.user}:${config.services.home-assistant.group}" "$RESTORE_COMPLETION_FLAG"
          echo "--- Home Assistant restore complete ---"
        '';
    };
}
