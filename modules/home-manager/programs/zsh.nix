{ config
, lib
, pkgs
, ...
}:
let
  inherit (config.sharedVariables) homeDir;
  inherit (config.sharedVariables) hostname;
in
{
  programs.zsh = lib.mkMerge [
    (
      let
        initExtraDarwin = ''
          if [[ $(ps -o command= -p "$PPID" | awk '{print $1}') != 'fish' ]]
          then
              exec fish -l
          fi
        '';

        initExtraLinux = ''
          source ~/.p10k.zsh

          export maestral="python3 -m maestral"
        '';

        initMxwDalco02 = ''
          export CONAN_HOME=/opt/mll_build/conan2/
          export MLL_ROOT=/opt/mll_root

          PATH=$MLL_ROOT/bin:$PATH
          LD_LIBRARY_PATH=$MLL_ROOT/lib:$MLL_ROOT/lib64:$LD_LIBRARY_PATH
          PKG_CONFIG_PATH=$MLL_ROOT/lib/pkgconfig:$PKG_CONFIG_PATH
          CMAKE_PREFIX_PATH=$MLL_ROOT:$CMAKE_PREFIX_PATH
          CPATH=$MLL_ROOT/include:$CPATH
        '';
      in
      {
        initExtra = lib.optionalString pkgs.stdenv.isDarwin initExtraDarwin
          + lib.optionalString pkgs.stdenv.isLinux initExtraLinux
          + lib.optionalString (hostname == "mxw-dalco02") initMxwDalco02;
      }
    )
    {
      autocd = true;

      enableCompletion = true;
      autosuggestion.enable = true;
      enable = true;

      shellAliases = {
        vim = "nvim";
        ip = "ip --color=auto";
        ll = "ls -lFha --color=auto";
        ls = "ls --color=auto";
        mkdir = "mkdir -p";
        diff = "colordiff";
        df = "df -Tha --total";
        du = "du -ach";
        ps = "ps auxf";
        ssh = "TERM=xterm-256color ssh";
      };
      oh-my-zsh = {
        enable = true;
        plugins = [
          "git"
        ];
      };

      plugins = [
        {
          name = "powerlevel10k";
          src = "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/";
          file = "powerlevel10k.zsh-theme";
        }
        {
          name = "zsh-syntax-highlighting";
          src =
            pkgs.fetchFromGitHub
              {
                owner = "zsh-users";
                repo = "zsh-syntax-highlighting";
                rev = "db6cac391bee957c20ff3175b2f03c4817253e60";
                sha256 = "0d9nf3aljqmpz2kjarsrb5nv4rjy8jnrkqdlalwm2299jklbsnmw";
              };
        }
        {
          name = "nix-shell";
          src =
            pkgs.fetchFromGitHub
              {
                owner = "chisui";
                repo = "zsh-nix-shell";
                rev = "03a1487655c96a17c00e8c81efdd8555829715f8";
                sha256 = "1avnmkjh0zh6wmm87njprna1zy4fb7cpzcp8q7y03nw3aq22q4ms";
              };
        }
      ];
    }
  ];
}
