{
  config,
  ...
}:
{
  programs.ssh = {
    enable = true;
    matchBlocks = {
      "maloja" = {
        hostname = "${config.networkLevelVariables.ipMap.maloja}";
        user = "worker";
        port = 22023;
        identityFile = "/Users/iilak/.ssh/maloja_access";
        identitiesOnly = true;
        extraOptions = {
          SetEnv = "TERM=xterm-256color";
        };
      };
      "bernina" = {
        hostname = "${config.networkLevelVariables.ipMap.bernina}";
        user = "worker";
        port = 22023;
        identityFile = "/Users/iilak/.ssh/maloja_access";
        identitiesOnly = true;
        extraOptions = {
          SetEnv = "TERM=xterm-256color";
        };
      };
    };
  };
}
