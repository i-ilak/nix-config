{
  config,
  inputs,
  ...
}:
{
  sops = {
    secrets = {
      acme-b2-endpoint = {
        key = "acme/b2/endpoint";
        sopsFile = "${inputs.nix-secrets}/secrets/private_shared.yaml";
        owner = "root";
        group = "backup";
        mode = "0440";
      };
      acme-b2-bucket_name = {
        key = "acme/b2/bucket_name";
        sopsFile = "${inputs.nix-secrets}/secrets/private_shared.yaml";
        owner = "root";
        group = "backup";
        mode = "0440";
      };
      acme-b2-account_id = {
        key = "acme/b2/account_id";
        sopsFile = "${inputs.nix-secrets}/secrets/private_shared.yaml";
        owner = "root";
        group = "backup";
        mode = "0440";
      };
      acme-b2-application_key = {
        key = "acme/b2/application_key";
        sopsFile = "${inputs.nix-secrets}/secrets/private_shared.yaml";
        owner = "root";
        group = "backup";
        mode = "0440";
      };
    };
    templates = {
      "acme-repositoryFile" = {
        content = ''
          s3:${config.sops.placeholder."acme-b2-endpoint"}/${config.sops.placeholder."acme-b2-bucket_name"}
        '';
        owner = "root";
        group = "backup";
        mode = "0440";
      };
      "acme-accessFile" = {
        content = ''
          AWS_ACCESS_KEY_ID="${config.sops.placeholder."acme-b2-account_id"}"
          AWS_SECRET_ACCESS_KEY="${config.sops.placeholder."acme-b2-application_key"}"
        '';
        owner = "root";
        group = "backup";
        mode = "0440";
      };
    };
  };
}
