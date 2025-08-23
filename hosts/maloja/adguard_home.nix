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
            "1.1.1.1"
            "1.0.0.1"
            "8.8.8.8"
            "9.9.9.9"
            "149.112.112.112"
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
        };
        # filters =
        #   map
        #     (url: {
        #       enabled = true;
        #       url = url;
        #     })
        #     [
        #       "https://adguardteam.github.io/HostlistsRegistry/assets/filter_9.txt"
        #       "https://adguardteam.github.io/HostlistsRegistry/assets/filter_11.txt"
        #     ];
        schema_version = 29;
      };
    };
}
