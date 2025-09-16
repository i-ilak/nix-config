{
  config,
  ...
}:
{
  services.adguardhome =
    let
      inherit (config.sharedVariables) ip;
      inherit (config.sharedVariables) gatewayIp;
      inherit (config.sharedVariables) publicDomain;
      inherit (config.sharedVariables) localDomainName;
      inherit (config.sharedVariables) unbound;
      inherit (config.sharedVariables.adguardhome) port;
    in
    {
      enable = true;
      settings = {
        http = {
          address = "127.0.0.1:${port}";
        };
        dns = {
          upstream_dns = [
            "127.0.0.1:${builtins.toString unbound.port}"
            "::1:${builtins.toString unbound.port}"
          ];
        };
        dhcp = {
          enabled = true;
          interface_name = "enp89s0";
          dhcpv4 = {
            gateway_ip = "${gatewayIp}";
            subnet_mask = "255.255.255.0";
            range_start = "192.168.1.100";
            range_end = "192.168.1.200";
            lease_duration = 86400; # 1 day in sec
          };
          local_domain_name = "${localDomainName}";
        };
        users = [
          {
            name = "admin";
            password = "$2y$10$Pg5LMXZPPyCaYnxu8x.W.uCw8r07pBXM7L9MQVNiOTHcRHxsWuzDK";
          }
        ];
        filtering = {
          protection_enabled = true;
          filtering_enabled = true;

          parental_enabled = false;
          safe_search = {
            enabled = false;
          };
          rewrites = [
            {
              domain = "auth.${publicDomain}";
              answer = "${ip}";
            }
            {
              domain = "home.${publicDomain}";
              answer = "${ip}";
            }
            {
              domain = "adguard.${publicDomain}";
              answer = "${ip}";
            }
            {
              domain = "jellyfin.${publicDomain}";
              answer = "${ip}";
            }
            {
              domain = "paperless.${publicDomain}";
              answer = "${ip}";
            }
          ];
          user_rules = [
            "@@||${localDomainName}^"
          ];
        };
        filters =
          map
            (url: {
              enabled = true;
              inherit url;
            })
            [
              "https://big.oisd.nl"
              "https://adguardteam.github.io/HostlistsRegistry/assets/filter_9.txt"
              "https://adguardteam.github.io/HostlistsRegistry/assets/filter_11.txt"
              "https://badmojr.github.io/1Hosts/Pro/adblock.txt"
              "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/pro.plus.txt"
              "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/tif.txt"
              "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/spam-tlds.txt"
              "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/hoster.txt"
            ];
        schema_version = 29;
      };
    };
}
