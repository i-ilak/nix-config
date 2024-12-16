{ config
, ...
}:
let
  user = config.sharedVariables.user;
in
{
  home-manager.users.${user}.programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };
}
