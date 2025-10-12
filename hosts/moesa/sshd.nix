{
  lib,
  ...
}:
{
  imports = [
    ../../modules/nixos/hardening/sshd.nix
  ];

  services.openssh.settings = lib.mkForce {
    PermitRootLogin = "prohibit-password";
    AllowUsers = [
      "root"
    ];
  };
}
