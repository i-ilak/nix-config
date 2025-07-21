_: {
  services.openssh = {
    enable = true;
    # FIXME: !!!!!!!!!!!
    settings.PasswordAuthentication = true;
    settings.PermitRootLogin = "yes";
    ports = [ 22023 ];
    extraConfig = ''
      AllowTcpForwarding yes
      X11Forwarding no
      AllowAgentForwarding no
      AllowStreamLocalForwarding no
    '';
    hostKeys = [
      {
        type = "ed25519";
        path = "/etc/ssh/ssh_host_ed25519_key";
      }
    ];
  };
}
