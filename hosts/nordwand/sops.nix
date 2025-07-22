{
  inputs,
  ...
}:
{
  sops = {
    defaultSopsFile = "${inputs.nix-secrets}/secrets/nordwand.yaml";
    age = {
      sshKeyPaths = [ "/persist/etc/ssh/ssh_host_ed25519_key" ];
    };
    secrets = {
      user-root-password = {
        key = "user/root/password";
        owner = "root";
        group = "root";
        mode = "0400";
        neededForUsers = true;
      };
      tailscale_auth_key = {
        owner = "root";
        group = "root";
        mode = "0400";
      };
      cloudflare_authenticated_origin_pull_ca = {
        key = "cloudflared/authenticated_origin_pull_ca";
        owner = "caddy";
        group = "caddy";
        mode = "0440";
      };
      cloudflared_origin_cert_pem = {
        key = "cloudflared/origin_cert_pem";
        owner = "caddy";
        group = "caddy";
        mode = "0440";
      };
      cloudflared_origin_cert_private_key = {
        key = "cloudflared/origin_cert_private_key";
        owner = "caddy";
        group = "caddy";
        mode = "0440";
      };
      # vaultwarden_admin_token = {
      #   key = "vaultwarden/admin_token";
      #   # nix-shell -p vaultwarden --run "vaultwarden hash"
      #   owner = "vaultwarden";
      #   group = "vaultwarden";
      #   mode = "0400";
      # };
    };
  };
}
