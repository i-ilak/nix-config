{
  config,
  ...
}:
{
  sops.templates."cloudflared_dns_api_token" = {
    content = ''
      CLOUDFLARE_DNS_API_TOKEN=${config.sops.placeholder.cloudflared_dns_api_token}
    '';
    owner = "root";
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "${config.sharedVariables.acmeEmail}";

    certs."${config.sharedVariables.domain}" = {
      inherit (config.services.caddy) group;
      domain = "${config.sharedVariables.domain}";
      dnsProvider = "cloudflare";
      dnsResolver = "1.1.1.1:53";
      dnsPropagationCheck = true;
      environmentFile = config.sops.templates."cloudflared_dns_api_token".path;
    };
  };

}
