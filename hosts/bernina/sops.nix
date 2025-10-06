{
  inputs,
  ...
}:
{
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  sops =
    let
      secretsPath = inputs.nix-secrets;
    in
    {
      secrets = {
        "user-root-password" = {
          sopsFile = "${secretsPath}/secrets/private_shared.yaml";
          key = "user/root/password";
          neededForUsers = true;
        };
        "user-worker-password" = {
          sopsFile = "${secretsPath}/secrets/private_shared.yaml";
          key = "user/worker/password";
          neededForUsers = true;
        };
      };
      age = {
        sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      };
    };

}
