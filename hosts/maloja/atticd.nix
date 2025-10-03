{
  config,
  inputs,
  ...
}:
{
  sops =
    let
      secretsPath = inputs.nix-secrets;
    in
    {
      secrets."attic_server_token" = {
        sopsFile = "${secretsPath}/secrets/maloja/general.yaml";
        owner = "${config.services.atticd.user}";
      };
      templates = {
        atticdEnvironmentFile = {
          content = ''
            ATTIC_SERVER_TOKEN_RS256_SECRET_BASE64=${config.sops.placeholder."attic_server_token"}
          '';
          owner = "${config.services.atticd.user}";
        };
      };
    };

  services.atticd = {
    enable = true;
    mode = "monolithic";
    environmentFile = config.sops.templates.atticdEnvironmentFile.path;
    settings = {
      listen = "127.0.0.1:${builtins.toString config.sharedVariables.atticd.port}";
      allowed-hosts = [
        "10.10.0.0/16" # default
        "10.30.0.0/16" # internal
      ];
      api-endpoint = "https://cache.nix.${config.sharedVariables.publicDomain}/";
      database = {
        url = "sqlite:///share/nix/attic/server.db";
      };
      storage = {
        type = "local";
        path = "/share/nix/attic/cache";
      };
    };
  };

  systemd.services.atticd = {
    wants = [
      "network-online.target"
      "share-nix-attic.mount"
    ];
  };
}
