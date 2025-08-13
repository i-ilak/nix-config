{
  description = "General Purpose Configuration for macOS and NixOS";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    # Fix nixpkgs-unstable to commit from 17.07.25, since we need some changes from
    # after 25.05, but dont want to constantly pull unstable
    nixpkgs-unstable.url = "github:nixos/nixpkgs/e139aa6a2b5f1f42d682a1fbc60abd355d2b4771";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew = {
      url = "github:zhaofengli-wip/nix-homebrew";
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:i-ilak/nixvim-config";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ghostty = {
      url = "github:ghostty-org/ghostty";
    };
    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    aerospace-taps = {
      url = "github:nikitabobko/homebrew-tap";
      flake = false;
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-secrets = {
      url = "git+ssh://git@github.com/i-ilak/nix-secrets?shallow=1&ref=main";
      flake = false;
    };
    impermanence = {
      url = "github:nix-community/impermanence";
    };
    deadnix = {
      url = "github:astro/deadnix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-config-helper = {
      url = "github:i-ilak/nix-config-helper";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    authentik-nix = {
      url = "github:nix-community/authentik-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      pre-commit-hooks,
      treefmt-nix,
      deadnix,
      nix-config-helper,
      ...
    }@inputs:
    let
      devShell =
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          preCommitCheck = self.checks.${system}.pre-commit-check;
        in
        {
          default =
            with pkgs;
            mkShell {
              inherit (preCommitCheck) shellHook;
              buildInputs = preCommitCheck.enabledPackages;
              nativeBuildInputs = with pkgs; [
                bashInteractive
                git
              ];
            };
        };
    in
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        treefmt = treefmt-nix.lib.evalModule pkgs ./modules/shared/format.nix;
      in
      {
        packages.default = nix-config-helper.packages.${system}.default;

        apps.default = {
          inherit (nix-config-helper.packages.${system}.default) meta;
          type = "app";
          program = "${nix-config-helper.apps.${system}.default.program}";
        };

        checks = {
          pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run {
            src = self;
            hooks = {
              nixfmt-rfc-style.enable = true;
              deadnix.enable = true;
              statix.enable = true;
              trufflehog.enable = true;
              check-added-large-files.enable = true;
              check-executables-have-shebangs.enable = true;
              check-shebang-scripts-are-executable.enable = true;
              end-of-file-fixer.enable = true;
              ripsecrets.enable = true;
              flake-checker.enable = true;
            };
          };
        };

        formatter = treefmt.config.build.wrapper;
        devShells = devShell system;
      }
    )
    // {
      darwinConfigurations = {
        macbook = import ./hosts/macbook/nix-darwin.nix {
          inherit inputs;
        };
      };

      homeConfigurations = {
        mxw-dalco01 = import ./hosts/mxw-dalco01/home-manager.nix {
          inherit nixpkgs inputs;
        };
      };

      nixosConfigurations = {
        maloja = import ./hosts/maloja/nixos.nix {
          inherit nixpkgs inputs;
        };
        albula = import ./hosts/albula/nixos.nix {
          inherit nixpkgs inputs;
        };
        iso = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";

          modules = [
            "${nixpkgs}/nixos/modules/installer/cd-dvd/iso-image.nix"

            (
              { pkgs, ... }:
              {
                boot.kernel.sysctl."fs.file-max" = "1048576";
                security.pam.loginLimits = [
                  {
                    domain = "*";
                    type = "soft";
                    item = "nofile";
                    value = "524288";
                  }
                  {
                    domain = "*";
                    type = "hard";
                    item = "nofile";
                    value = "1048576";
                  }
                ];
                environment.systemPackages = with pkgs; [
                  vim
                  git
                  wget
                  htop
                  nix-tree # A useful tool for exploring Nix derivations
                ];

                networking.hostName = "nixos-high-limit-iso";
                services.getty.autologinUser = "nixos";
              }
            )
          ];
        };
      };
    };
}
