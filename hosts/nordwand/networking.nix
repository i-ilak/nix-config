{
  config,
  ...
}:
{
  networking = {
    hostName = "nordwand";
    firewall = {
      enable = true;
      allowedTCPPorts = [
      ];
    };
    enableIPv6 = false;
  };
}
