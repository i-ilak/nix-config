{
  config,
  ...
}:
let
  inherit (config.sharedVariables) publicDomain;
in
{
  sops = {
    secrets = {
      "cloudflare-dns-api-token" = {
        key = "cloudflare/dns_api_token";
        owner = "caddy";
        group = "caddy";
        mode = "0400";
      };
    };
    templates."acme-cloudflare-env-file" = {
      content = ''
        CLOUDFLARE_DNS_API_TOKEN=${config.sops.placeholder."cloudflare-dns-api-token"}
      '';
      owner = "caddy";
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "ivan.ilak@hotmail.com";

    certs."${publicDomain}" = {
      inherit (config.services.caddy) group;

      domain = "${publicDomain}";
      extraDomainNames = [ "*.${publicDomain}" ];
      dnsProvider = "cloudflare";
      dnsResolver = "1.1.1.1:53";
      dnsPropagationCheck = true;
      environmentFile = config.sops.templates."acme-cloudflare-env-file".path;
    };
  };

}
