_: {
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      AllowTcpForwarding = true;
      X11Forwarding = false;
      AllowAgentForwarding = false;
      AllowStreamLocalForwarding = false;
      AllowUsers = [ "iilak" ];
    };
    ports = [ 22023 ];
    hostKeys = [
      {
        type = "ed25519";
        path = "/etc/ssh/ssh_host_ed25519_key";
      }
    ];
  };
}
