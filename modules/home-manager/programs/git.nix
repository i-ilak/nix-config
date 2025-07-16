{ config
, pkgs
, ...
}:
let
  inherit (config.sharedVariables) hostname;

  allowed_signers_content =
    if hostname == "mxw-dalco01" then
      ''
        * ${config.sops.placeholder."git_signing_ssh_key_work"}
      ''
    else
      ''
        * ${config.sops.placeholder."git_signing_ssh_key_public"}
      '';
in
{
  sops.templates."allowed_signers".content = allowed_signers_content;

  programs.git =
    let
      name = "Ivan Ilak";
      email = if hostname == "mxw-dalco01" then "ivan.ilak@mxwbio.com" else "ivan.ilak@hotmail.com";

      signing = {
        format = "ssh";
        key =
          if hostname == "mxw-dalco01" then
            "${config.sops.secrets."git_signing_ssh_key_work".path}"
          else
            "${config.sops.secrets."git_signing_ssh_key_public".path}";
        signByDefault = true;
      };

      # The user account of mxw-dalco01 is managed by the Active Directory (AD)
      # As a consequence, the user Id for the account is missing from /etc/passwd and needs to be loaded from elsewhere
      # The issue can be traced back to using the wrong shared-object that is associated to managing the AD.
      # We essentially wrap the git command and prepend the correct shared object to be loaded
      adCustomGitPackage =
        let
          inherit (pkgs) git;
        in
        pkgs.writeScriptBin "git" ''
          #!${pkgs.bash}/bin/bash
          export LD_PRELOAD="/usr/lib/x86_64-linux-gnu/libnss_sss.so.2"
          exec "${git}/bin/git" "$@"
        '';
      git-package = if hostname == "mxw-dalco01" then adCustomGitPackage else pkgs.git;
    in
    {
      enable = true;
      package = git-package;
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
          gpgsign = true;
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
        tag = {
          sort = "version:refname";
          gpgSign = true;
        };
        gpg.ssh.allowedSignersFile = "${config.sops.templates."allowed_signers".path}";
      };
      inherit signing;
    };
}
