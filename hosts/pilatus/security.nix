{ inputs
, pkgs
, config
, ...
}:
let
  secretspath = builtins.toString inputs.nix-secrets;
in
{

  sops = {
    defaultSopsFile = "${secretspath}/secrets/pilatus.yaml";
    secrets.user-dev-password = {
      key = "user/dev/password";
      neededForUsers = true;
    };
    age = {
      sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    };
    #
    # secrets = {
    #   sopsFile = "./secrets/shared.yaml";
    #   commonSshPort = { sopsPath = [ "ssh pilatus port" ]; };
    # };
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
