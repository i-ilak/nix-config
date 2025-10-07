{
  config,
  ...
}:
{
  networking = {
    inherit (config.sharedVariables) hostName;
    firewall = {
      enable = true;
      allowedTCPPorts = [
        80
        443
        53 # DNS
      ];
      allowedUDPPorts = [
        53 # DNS
        67 # DHCP
        68 # DHCP
      ];
    };
    defaultGateway = {
      address = "${config.networkLevelVariables.gatewayIp}";
    };
    useDHCP = false;
    interfaces."end0" = {
      ipv4 = {
        addresses = [
          {
            address = "${config.networkLevelVariables.ipMap.${config.networking.hostName}}";
            prefixLength = 24;
          }
        ];
      };
    };
  };

}
