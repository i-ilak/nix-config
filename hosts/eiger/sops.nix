{ inputs
, ...
}:
let
  secretspath = builtins.toString inputs.nix-secrets;
in
{
  sops = {
    defaultSopsFile = "${secretspath}/secrets/eiger.yaml";
    secrets = {
      user-worker-password = {
        key = "user/worker/password";
        neededForUsers = true;
      };
      user-root-password = {
        key = "user/root/password";
        neededForUsers = true;
      };
    };
    age = {
      sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    };
  };
}

