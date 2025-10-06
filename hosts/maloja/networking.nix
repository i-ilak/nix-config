{
  config,
  ...
}:
{

  networking = {
    inherit (config.sharedVariables) hostName;
    nameservers = [
      config.networkLevelVariables.ipMap.bernina
    ];
    firewall = {
      enable = true;
      allowedTCPPorts = [
        80
        443
      ];
    };
    defaultGateway = {
      address = "${config.networkLevelVariables.gatewayIp}";
    };
    useDHCP = false;
    interfaces."enp89s0" = {
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
