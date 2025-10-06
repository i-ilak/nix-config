{
  inputs,
  ...
}:
let
  secretspath = builtins.toString inputs.nix-secrets;
in
{
  imports = [
    ../../modules/shared/sops/restic.nix
  ];

  sops = {
    defaultSopsFile = "${secretspath}/secrets/maloja/general.yaml";
    secrets = {
      user-worker-password = {
        sopsFile = "${secretspath}/secrets/private_shared.yaml";
        key = "user/worker/password";
        neededForUsers = true;
      };
      user-root-password = {
        sopsFile = "${secretspath}/secrets/private_shared.yaml";
        key = "user/root/password";
        neededForUsers = true;
      };
    };
    age = {
      sshKeyPaths = [ "/persist/etc/ssh/ssh_host_ed25519_key" ];
    };
  };
}
