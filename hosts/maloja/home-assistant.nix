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
  # systemd.services.home-assistant-restore-from-backup =
  #   let
  #     baseDirPaperless = "/var/lib/hass";
  #   in
  #   {
  #     description = "Restore Home Assistant from S3 backup if not already done";
  #
  #     wantedBy = [ "multi-user.target" ];
  #     wants = [
  #       "network-online.target"
  #       "var-lib-hass.mount"
  #     ];
  #     after = [
  #       "network-online.target"
  #     ];
  #     before = [
  #       "home-assistant.service"
  #     ];
  #     unitConfig = {
  #       ConditionPathExists = "!${baseDirPaperless}/.restore_service_completed";
  #     };
  #
  #     serviceConfig = {
  #       Type = "oneshot";
  #       User = "root";
  #       Group = "backup";
  #       EnvironmentFile = config.sops.templates."accessFile".path;
  #       WorkingDirectory = "${baseDirPaperless}";
  #     };
  #
  #     script =
  #       # bash
  #       ''
  #         RESTORE_COMPLETION_FLAG="${baseDirPaperless}/.restore_service_completed"
  #
  #         if [ -f "$RESTORE_COMPLETION_FLAG" ]; then
  #           echo "Restore completion flag found ($RESTORE_COMPLETION_FLAG). Skipping restore."
  #           exit 0
  #         fi
  #
  #         echo "--- Starting Paperless-NGX restore from S3 backup ---"
  #
  #         echo "Restoring latest backup to ${backupDir}..."
  #         ${pkgs.restic}/bin/restic                                               \
  #           --repository-file "${config.sops.templates."repositoryFile".path}"    \
  #           --password-file "${config.sops.secrets."restic-password-file".path}"  \
  #           restore latest:${backupDir} --target ${backupDir}
  #
  #         chown -R paperless:paperless "${backupDir}"
  #
  #         echo "Importing documents into Paperless-NGX..."
  #         ${pkgs.su}/bin/su -s /bin/sh paperless -c "
  #           export PAPERLESS_DATA_DIR=${dataDir}
  #           export PAPERLESS_MEDIA_ROOT=${mediaDir}
  #           export PAPERLESS_CONSUMPTION_DIR=${dataDir}/consume
  #           ${pkgs.paperless-ngx}/bin/paperless-ngx migrate
  #           ${pkgs.paperless-ngx}/bin/paperless-ngx document_importer '${backupDir}'
  #         "
  #
  #         echo "Cleaning up temporary directory..."
  #         rm -rf "$RESTORE_DIR"
  #
  #         echo "Creating restore completion flag file: $RESTORE_COMPLETION_FLAG."
  #         touch "$RESTORE_COMPLETION_FLAG"
  #         chown "${config.services.paperless.user}:paperless" "$RESTORE_COMPLETION_FLAG"
  #         echo "--- Paperless-NGX restore complete ---"
  #       '';
  #   };
}
