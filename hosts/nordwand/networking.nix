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
        443
      ];
    };
    enableIPv6 = false;
    extraHosts = ''
      127.0.0.1 auth.${config.sharedVariables.domain}
      127.0.0.1 home.${config.sharedVariables.domain}
    '';
  };
}
