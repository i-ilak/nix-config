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
      cloudflared_test_tunnel_id = {
        key = "cloudflared/test/tunnel_id";
        owner = "cloudflared";
        group = "cloudflared";
        mode = "0400";
      };
      cloudflared_test_account_id = {
        key = "cloudflared/test/account_id";
        owner = "cloudflared";
        group = "cloudflared";
        mode = "0400";
      };
      cloudflared_test_tunnel_secret = {
        key = "cloudflared/test/tunnel_secret";
        owner = "cloudflared";
        group = "cloudflared";
        mode = "0400";
      };
      cloudflared_dns_api_token = {
        key = "cloudflared/dns_api_token";
        owner = "root";
        group = "root";
        mode = "0400";
      };
      cloudflare_origin_pulls_ca_cert = {
        key = "cloudflare/origin_pulls_ca_cert";
        owner = "caddy";
        group = "caddy";
        mode = "0440";
      };
      vaultwarden_admin_token = {
        key = "vaultwarden/admin_token";
        # nix-shell -p vaultwarden --run "vaultwarden hash"
        owner = "vaultwarden";
        group = "vaultwarden";
        mode = "0400";
      };
      acme_email = {
        key = "acme/email";
        owner = "root";
        group = "root";
        mode = "0400";
      };
    };
  };
}
