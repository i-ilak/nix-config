{
  config,
  ...
}:
let
  inherit (config.sharedVariables) hostname;
in
{
  networking = {
    networkmanager.enable = true;
    hostName = hostname;
    firewall = {
      enable = true;
      allowedTCPPorts = [
        80
        443
        22022
      ];
    };
  };

}
