{
  config,
  ...
}:
let
  inherit (config.sharedVariables) interface;
in
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
    interfaces.${interface} = {
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
