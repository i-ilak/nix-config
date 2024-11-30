{ config
, lib
, pkgs
, ...
}: {
  programs.zsh = lib.mkMerge [
    (
      let
        initExtraDarwin = ''
          # source the nix profiles
          if [[ -r "${config.home.homeDirectory}/.nix-profile/etc/profile.d/nix.sh" ]]; then
            source "${config.home.homeDirectory}/.nix-profile/etc/profile.d/nix.sh"
          fi
          source ~/.p10k.zsh

          export PATH="$HOME/.cargo/bin:$PATH"
          export EDITOR="vim"
          export PATH="/usr/local/bin:$PATH"
          export maestral="python3 -m maestral"
          export PATH="/Applications/ArmGNUToolchain/13.2.Rel1/aarch64-none-elf/bin:$PATH"
          export PATH="/opt/homebrew/bin:$PATH"
          export HDF5_DIR=$(brew --prefix hdf5)
        '';

        initExtraLinux = ''
          source ~/.p10k.zsh

          export maestral="python3 -m maestral"
        '';
      in
      {
        initExtra = lib.optionalString pkgs.stdenv.isDarwin initExtraDarwin + lib.optionalString pkgs.stdenv.isLinux initExtraLinux;
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
        mkdir = "mkdir -p";
        diff = "colordiff";
        df = "df -Tha --total";
        du = "du -ach | sort -h";
        ps = "ps auxf";
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
