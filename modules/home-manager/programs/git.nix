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
        branch.sort = "-commiterdate";
        column.ui = "auto";
        commit = {

          gpgsign = false;
          verbose = true;
        };
        core = {
          autocrlf = "input";
          editor = "vim";
          excludeFiles = "~/.gitignore";
          fsmonitor = true;
          untrackedCache = true;
        };
        diff = {
          algorithm = "histogram";
          colorMoved = "plain";
          mnemonicPrefix = true;
          renames = true;
        };
        fetch = {
          prune = true;
          pruneTags = true;
          all = true;
        };
        help.autocorrect = "prompt";
        init.defaultBranch = "main";
        merge.conflictstyle = "zdiff3";
        pull.rebase = true;
        push = {
          autoSetupRemote = true;
          default = "simple";
          followTags = true;
        };
        rebase = {
          autoStash = true;
          autoSquash = true;
          updateRefs = true;
        };
        rerere = {
          enabled = true;
          autoupdate = true;
        };
        tag.sort = "version:refname";
      };
    };
}
