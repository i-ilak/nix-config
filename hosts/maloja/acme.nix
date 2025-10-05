{
  config,
  pkgs,
  ...
}:
let
  inherit (config.networkLevelVariables) publicDomain;
  baseDirAcme = "/var/lib/acme";
in
{
  imports = [
    ../../modules/shared/sops/acme.nix
  ];

  sops = {
    secrets = {
      "cloudflare-dns-api-token" = {
        key = "cloudflare/dns_api_token";
        owner = "caddy";
        group = "caddy";
        mode = "0400";
      };
    };
    templates = {
      "acme-cloudflare-env-file" = {
        content = ''
          CLOUDFLARE_DNS_API_TOKEN=${config.sops.placeholder."cloudflare-dns-api-token"}
        '';
        owner = "caddy";
      };
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "ivan.ilak@hotmail.com";

    certs = {
      "${publicDomain}" = {
        inherit (config.services.caddy) group;

        domain = "${publicDomain}";
        extraDomainNames = [ "*.${publicDomain}" ];
        dnsProvider = "cloudflare";
        dnsResolver = "1.1.1.1:53";
        dnsPropagationCheck = true;
        environmentFile = config.sops.templates."acme-cloudflare-env-file".path;
      };
    };
  };

  services.restic.backups.acme = {
    initialize = true;
    paths = [
      "${baseDirAcme}"
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

    environmentFile = config.sops.templates."acme-accessFile".path;
    repositoryFile = config.sops.templates."acme-repositoryFile".path;
    passwordFile = config.sops.secrets."restic-password-file".path;
  };

  systemd.services.acme-restore-from-backup = {
    description = "Restore ACME/Lets Encrypt certificates from S3 backup if not already done";

    wantedBy = [ "multi-user.target" ];
    requires = [
      "network-online.target"
    ];
    before = [
      "var-lib-acme.mount"
      "acme-${publicDomain}.service"
    ];
    unitConfig = {
      ConditionPathExists = "!${baseDirAcme}/.restore_service_completed";
    };

    serviceConfig = {
      Type = "oneshot";
      User = "root";
      Group = "backup";
      EnvironmentFile = config.sops.templates."acme-accessFile".path;
      WorkingDirectory = "${baseDirAcme}";
    };

    script =
      # bash
      ''
        RESTORE_COMPLETION_FLAG="${baseDirAcme}/.restore_service_completed"

        if [ -f "$RESTORE_COMPLETION_FLAG" ]; then
          echo "Restore completion flag found ($RESTORE_COMPLETION_FLAG). Skipping restore."
          exit 0
        fi

        echo "--- Starting Lets Encrypt certifactes restore from S3 backup ---"

        echo "Restoring latest backup to ${baseDirAcme}..."
        ${pkgs.restic}/bin/restic                                                           \
          --repository-file "${config.sops.templates."acme-repositoryFile".path}"           \
          --password-file "${config.sops.secrets."restic-password-file".path}"              \
          restore latest:${baseDirAcme} --target ${baseDirAcme}
        echo "Creating restore completion flag file: $RESTORE_COMPLETION_FLAG."
        touch "$RESTORE_COMPLETION_FLAG"
        chown acme:acme "$RESTORE_COMPLETION_FLAG"

        echo "--- ACME certs restore complete ---"
      '';
  };
}
