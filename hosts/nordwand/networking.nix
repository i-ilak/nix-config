_: {
  networking = {
    hostName = "nordwand";
    firewall = {
      enable = true;
      allowedUDPPorts = [ 7844 ];
    };
    enableIPv6 = false;
  };
}
