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
      cloudflare_authenticated_origin_pull_ca = {
        key = "cloudflared/authenticated_origin_pull_ca";
        owner = "caddy";
        group = "origin_pull";
        mode = "0440";
      };
    };
  };
}
