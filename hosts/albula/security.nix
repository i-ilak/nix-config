{
  inputs,
  pkgs,
  ...
}:
let
  secretspath = builtins.toString inputs.nix-secrets;
in
{
  sops = {
    defaultSopsFile = "${secretspath}/secrets/albula.yaml";
    secrets.user-dev-password = {
      key = "user/dev/password";
      neededForUsers = true;
    };
    age = {
      sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    };
  };

  security.sudo = {
    enable = true;
    extraRules = [
      {
        commands = [
          {
            command = "${pkgs.systemd}/bin/reboot";
            options = [ "NOPASSWD" ];
          }
        ];
        groups = [ "wheel" ];
      }
    ];
  };

}
