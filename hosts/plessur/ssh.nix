_: {
  programs.ssh = {
    enable = true;
    matchBlocks = {
      "maloja" = {
        hostname = "192.168.1.2";
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
