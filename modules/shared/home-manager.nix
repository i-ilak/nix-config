{ config, pkgs, lib, ... }:

let
  name = "Ivan Ilak";
  user = "iilak";
  email = "ivan.ilak@hotmail.com";
in
{
  direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  zsh = lib.mkMerge [
    ({
      initExtra = lib.optionalString pkgs.stdenv.isDarwin ''
        # source the nix profiles
        if [[ -r "${config.home.homeDirectory}/.nix-profile/etc/profile.d/nix.sh" ]]; then
          source "${config.home.homeDirectory}/.nix-profile/etc/profile.d/nix.sh"
        fi
        source ~/.p10k.zsh

        export PATH="$HOME/.cargo/bin:$PATH"
        export PATH="/usr/local/bin:$PATH"
        export VIRTUAL_ENV="$HOME/.pyenv/versions/default"
        export maestral="python3 -m maestral"
        export PATH="/Applications/ArmGNUToolchain/13.2.Rel1/aarch64-none-elf/bin:$PATH"
        export PATH="/opt/homebrew/bin:$PATH"
        export HDF5_DIR=$(brew --prefix hdf5)
      '';
    })
    {
      autocd = true;

      enableCompletion = true;
      autosuggestion.enable = true;
      enable = true;

      shellAliases = {
        vim = "nvim";
        cmake_format = "$HOME/.pyenv/versions/default/bin/cmake-format -i";
        ip = "ip --color=auto";
      };

      plugins = [
        {
          name = "powerlevel10k";
          src = "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/";
          file = "powerlevel10k.zsh-theme";
        }
        {
          name = "zsh-syntax-highlighting";
          src = pkgs.fetchFromGitHub
            {
              owner = "zsh-users";
              repo = "zsh-syntax-highlighting";
              rev = "db6cac391bee957c20ff3175b2f03c4817253e60";
              sha256 = "0d9nf3aljqmpz2kjarsrb5nv4rjy8jnrkqdlalwm2299jklbsnmw";
            };
        }
        {
          name = "nix-shell";
          src = pkgs.fetchFromGitHub
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

  git = {
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
      commit.gpgsign = true;
      pull.rebase = true;
      rebase.autoStash = true;
    };
  };
}
