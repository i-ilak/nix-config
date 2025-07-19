_: {
  networking = {
    hostName = "nordwand";
    firewall = {
      enable = true;
      allowedTCPPorts = [
        80
        443
      ]; # For Caddy's ACME challenge & HTTPS termination
    };
  };

}
