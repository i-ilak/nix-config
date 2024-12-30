{ config
, ...
}:
let
  inherit (config.sharedVariables) user;
in
{
  programs.git =
    let
      name = "Ivan Ilak";
      email = "ivan.ilak@hotmail.com";
    in
    {
      enable = true;
      ignores = [ "*.swp" ];
      userName = name;
      userEmail = email;
      lfs = {
        enable = true;
      };
      extraConfig = {
        init.defaultBranch = "main";
        core = {
          editor = "vim";
          autocrlf = "input";
        };
        commit.gpgsign = false;
        pull.rebase = true;
        rebase.autoStash = true;
        push.autoSetupRemote = true;
      };
    };
}
