{
  inputs,
  ...
}:
let
  secretspath = builtins.toString inputs.nix-secrets;
in
{
  sops = {
    defaultSopsFile = "${secretspath}/secrets/maloja/general.yaml";
    secrets = {
      user-worker-password = {
        sopsFile = "${secretspath}/secrets/shared.yaml";
        key = "user/worker/password";
        neededForUsers = true;
      };
      user-root-password = {
        sopsFile = "${secretspath}/secrets/shared.yaml";
        key = "user/root/password";
        neededForUsers = true;
      };
      restic-password-file = {
        key = "restic/password_file";
        owner = "root";
        group = "backup";
        mode = "0440";
      };
    };
    age = {
      sshKeyPaths = [ "/persist/etc/ssh/ssh_host_ed25519_key" ];
    };
  };
}
