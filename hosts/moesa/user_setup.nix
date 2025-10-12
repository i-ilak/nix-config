{
  config,
  ...
}:
{

  sops = {
    secrets = {
      user-root-password = {
        sopsFile = "${secretspath}/secrets/private_shared.yaml";
        key = "user/root/password";
        neededForUsers = true;
      };
    };
  };

  users = {
    mutableUsers = false;
    users = {
      root = {
        hashedPasswordFile = config.sops.secrets."user-root-password".path;
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOTlQXyssgPreQcwbsg54nMZUQD9IVIDEmfKn4ssXCfx"
        ];
      };
    };
  };
}
