{
  inputs,
  ...
}:
{
  sops = {
    secrets = {
      restic-password-file = {
        key = "restic/password_file";
        sopsFile = "${inputs.nix-secrets}/secrets/private_shared.yaml";
        owner = "root";
        group = "backup";
        mode = "0440";
      };
    };
  };
}
