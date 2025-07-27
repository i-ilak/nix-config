_: {
  networking = {
    hostName = "surselva";
    firewall = {
      enable = true;
      rejectPackets = false;
      checkReversePath = "strict";
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];
      trustedInterfaces = [ ];
      extraCommands = ''
        # --- FORWARD CHAIN ---
        # This machine must not act as a router. We explicitly drop all
        # forwarded packets. While this is the default, being explicit is safer.
        nft add rule inet filter forward drop

        # --- INPUT CHAIN (Traffic TO this machine) ---
        # The default policy for the input chain in NixOS is DROP. This is secure.
        # We will only add rules to allow essential incoming traffic.

        # Rule 1: Allow traffic that is part of a connection we initiated.
        # This is essential for getting replies from servers you connect to (e.g., web servers).
        nft add rule inet filter input ct state established,related accept

        # Rule 2: Allow all traffic on the loopback interface ("lo").
        # This is critical for internal services and applications to function correctly.
        nft add rule inet filter input iifname "lo" accept

        # All other unsolicited incoming traffic will be dropped by the default policy.


        # --- OUTPUT CHAIN (Traffic FROM this machine) ---
        # This is the most critical part for isolating the instance.
        # The default NixOS policy for this chain is ACCEPT. We will override this
        # by adding rules to create a strict "allow-list", ending with a final DROP.

        # Rule 1: Allow all outgoing traffic on the loopback interface.
        nft add rule inet filter output oifname "lo" accept

        # Rule 2: BLOCK all outgoing traffic to private IPv4 ranges.
        # This is the core of the local network isolation. This rule is processed
        # first for any non-loopback traffic, immediately stopping any attempt
        # to contact your local network.
        nft add rule inet filter output ip daddr { 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16, 169.254.0.0/16 } drop

        # Rule 3: BLOCK all outgoing traffic to private/local IPv6 ranges.
        # This provides defense-in-depth, even if you have IPv6 disabled.
        # It blocks Unique Local Addresses (ULA) and Link-Local addresses.
        nft add rule inet filter output ip6 daddr { fc00::/7, fe80::/10 } drop

        # Rule 4: BLOCK common broadcast and multicast traffic.
        nft add rule inet filter output ip daddr { 224.0.0.0/4, 255.255.255.255 } drop

        # Rule 5: ALLOW required outgoing traffic to the PUBLIC INTERNET.
        # These rules are only reached if the destination is NOT a private IP,
        # because the 'drop' rules above would have already matched and ended processing.
        nft add rule inet filter output tcp dport { 80, 443, 7844 } accept
        nft add rule inet filter output udp dport { 53, 123 } accept

        # Rule 6: FINAL DROP. This is the most important security improvement.
        # It drops any other outgoing packet that was not explicitly allowed above.
        # This enforces a strict "allow-list" and ensures no other connections can be made.
        nft add rule inet filter output drop
      '';
    };
    enableIPv6 = false;
  };
}
