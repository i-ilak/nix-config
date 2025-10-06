{
  config,
  pkgs,
  ...
}:
{
  imports = [
    ../../modules/shared/sops/acme.nix
    ../../modules/shared/sops/restic.nix
  ];

  systemd = {
    services = {
      acme-certs-sync =
        let
          baseDirAcme = "/var/lib/acme";
        in
        {
          description = "Sync certificates from restic backup";
          requires = [
            "adguardhome.service"
          ];

          serviceConfig = {
            Type = "oneshot";
            User = "root";
            Group = "backup";

            PrivateTmp = true;
            ReadWritePaths = [ "${baseDirAcme}" ];
            WorkingDirectory = "${baseDirAcme}";
            EnvironmentFile = config.sops.templates."acme-accessFile".path;
          };

          script = ''
            set -euo pipefail

            echo "Syncing Lets Encrypt certificates..."

            ${pkgs.restic}/bin/restic                                                           \
              --repository-file "${config.sops.templates."acme-repositoryFile".path}"           \
              --password-file "${config.sops.secrets."restic-password-file".path}"              \
              restore latest:${baseDirAcme} --target ${baseDirAcme}

            echo "Certificates synchronized successfully"

            systemctl reload caddy.service || true
          '';

          after = [ "network-online.target" ];
          wants = [ "network-online.target" ];
        };
      acme-certs-sync-firstrun = {
        description = "Ensure certificates are synced on first deployment";
        wantedBy = [ "multi-user.target" ];
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];

        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };

        script = ''
          echo "Boot detected, triggering certificate sync..."
          ${pkgs.systemd}/bin/systemctl start acme-certs-sync.service
        '';
      };
    };
    timers.acme-certs-sync = {
      description = "Daily certificate sync from restic";
      wantedBy = [ "timers.target" ];

      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
        RandomizedDelaySec = "30min";
      };
    };
    tmpfiles.rules = [
      "d /var/lib/acme 0755 root root -"
    ];
  };
}
