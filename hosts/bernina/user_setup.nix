{
  config,
  ...
}:
{

  users = {
    groups = {
      backup = { };
    };
    mutableUsers = false;
    users = {
      root = {
        hashedPasswordFile = config.sops.secrets."user-root-password".path;
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOTlQXyssgPreQcwbsg54nMZUQD9IVIDEmfKn4ssXCfx"
        ];
      };
      worker = {
        hashedPasswordFile = config.sops.secrets."user-worker-password".path;
        isNormalUser = true;
        extraGroups = [
          "systemd-journal"
        ];
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDKU+/RXjWLUzfRgMIhWnI4LD9Zh11BmCJsFaYNZNQqg"
        ];
      };
    };
  };

}
