{
  config,
  lib,
  ...
}:
{
  services.adguardhome =
    let
      inherit (config.networkLevelVariables) gatewayIp;
      inherit (config.networkLevelVariables) publicDomain;
      inherit (config.sharedVariables) unbound;
      inherit (config.sharedVariables.adguardhome) port;

      rewrites =
        let
          hosts = {
            maloja = [
              "paperless"
              "jellyfin"
              "home"
            ];
            bernina = [
              "adguard"
              "network"
            ];
          };

          makeRewrite = hostname: subdomain: {
            domain = "${subdomain}.${publicDomain}";
            answer = config.networkLevelVariables.ipMap.${hostname};
          };

          makeHostRewrites = hostname: subdomains: map (subdomain: makeRewrite hostname subdomain) subdomains;

          allRewrites = lib.mapAttrsToList makeHostRewrites hosts;
        in
        lib.flatten allRewrites;
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
          inherit rewrites;
          user_rules = [
            "@@||chaoticgood.management^$important"
            "@@||blog.nommy.moe^$important"
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
  systemd.services.adguardhome.requires = [ "unbound.service" ];
}
