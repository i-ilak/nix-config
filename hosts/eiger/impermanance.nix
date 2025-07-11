_:
{
  environment.persistence."/persist" = {
    directories = [
      "/etc/nixos"

      "/passwords"

      "/var/lib"
      "/var/log"
      "/var/lib/sops-nix"
      "/var/lib/hass"
    ];
    files = [
      "/etc/machine-id"

      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
    ];
  };

  fileSystems."/persist".neededForBoot = true;

  fileSystems."/" = {
    device = "tmpfs";
    fsType = "tmpfs";
    options = [ "defaults" "size=2G" "mode=755" ];
  };
}
