{
  inputs,
  config,
  ...
}:
{
  # READ: https://aottr.dev/posts/2024/08/homelab-setting-up-caddy-reverse-proxy-with-ssl-on-nixos/
  imports = [
    inputs.disko.nixosModules.disko
    inputs.impermanence.nixosModules.impermanence
    ./additional_config_parameters.nix
    ./disk-config.nix
    ./boot.nix
    ./impermanance.nix
    ./networking.nix
    ./sops.nix
    ../../modules/nixos/locale.nix
    ../../modules/nixos/hardening/audit.nix
    ../../modules/nixos/hardening/sudo.nix
    ../../modules/nixos/hardening/no-defaults.nix
    ../../modules/nixos/hardening/noexec.nix
    ./sshd.nix
    ./tailscale.nix
    ./cloudflared.nix
    ./security.nix
    ./caddy.nix
    ./vaultwarden.nix
  ];

  users = {
    groups.cloudflared = { };
    mutableUsers = false;
    users = {
      root.hashedPasswordFile = config.sops.secrets."user-root-password".path;
      cloudflared = {
        isSystemUser = true;
        group = "cloudflared";
      };
    };
  };

  nix.settings.allowed-users = [ "root" ];

  # DO NOT CHANGE, EVER.
  # Needs to be the version of the installer that was used to install the initial version of NixOS
  system.stateVersion = "25.05"; # Did you read the comment?
}
