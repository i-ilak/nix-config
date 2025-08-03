_: {
  networking = {
    hostName = "surselva";
    firewall.enable = false;
    nftables = {
      enable = true;
      checkRuleset = true;
      flushRuleset = true;
      ruleset =
        # bash
        ''
          # Define a table named 'filter' for both IPv4 and IPv6 ('inet' family).
          table inet filter {
              # Define local network ranges to block
              set local_networks {
                  type ipv4_addr
                  flags interval
                  elements = { 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16, 169.254.0.0/16 }
              }
              
              set local_networks_v6 {
                  type ipv6_addr
                  flags interval
                  elements = { fe80::/10, fc00::/7 }
              }

              chain forward {
                  type filter hook forward priority 0; policy drop;
              }
              
              chain input {
                  type filter hook input priority 0; policy drop;
                  ct state established,related accept
                  iifname "lo" accept
                  
                  # Block all traffic from local networks
                  ip saddr @local_networks drop
                  ip6 saddr @local_networks_v6 drop
              }
              
              chain output {
                  type filter hook output priority 0; policy drop;
                  oifname "lo" accept
                  
                  # Block outgoing traffic to local networks
                  ip daddr @local_networks drop
                  ip6 daddr @local_networks_v6 drop
                  
                  # Allow essential internet services
                  tcp dport { 80, 443 } accept
                  udp dport { 53, 123 } accept
                  
                  # Allow cloudflared tunnel traffic
                  # Cloudflare uses port 7844 for tunnel connections
                  tcp dport 7844 accept
                  tcp dport { 2052, 2053, 2082, 2083, 2086, 2087, 2095, 2096, 8080, 8443, 8880 } accept
              }
          }
        '';
    };
    enableIPv6 = false;
  };
}
