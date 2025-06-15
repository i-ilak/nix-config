{ pkgs
, config
, ...
}:
let
  inherit (config.sharedVariables) user;
in
{
  services = {
    openssh = {
      enable = true;
      ports = [ 11231 ];
      settings = {
        PasswordAuthentication = true;
        AllowUsers = [ "${user}" ];
        UseDns = true;
        X11Forwarding = false;
        PermitRootLogin = "prohibit-password";
      };

      # extraConfig = ''
      #   Port ${builtins.readFile config.sops.secrets.commonSshPort.path}
      # '';
    };

    displayManager = {
      defaultSession = "none+i3";
    };

    xserver = {
      enable = true;

      resolutions = [
        {
          x = 1920;
          y = 1200;
        }
      ];

      desktopManager = {
        xterm.enable = false;
      };

      windowManager.i3 = {
        enable = true;
        extraPackages = with pkgs; [
          dmenu
          i3status
          i3lock
          i3blocks
        ];
      };
    };
  };
}
