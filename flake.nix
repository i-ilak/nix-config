{
  description = "General Purpose Configuration for macOS and NixOS";
  inputs = {
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.2411.711349.tar.gz";
    home-manager = {
      url = "https://flakehub.com/f/nix-community/home-manager/0.2411.3873.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew = {
      url = "github:zhaofengli-wip/nix-homebrew";
      inputs.nixpkgs.follows = "nixpkgs";
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
      url = "https://flakehub.com/f/nix-community/disko/1.10.0.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:i-ilak/nixvim-config";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pre-commit-hooks = {
      url = "https://flakehub.com/f/cachix/git-hooks.nix/0.1.946.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils = {
      url = "https://flakehub.com/f/numtide/flake-utils/0.1.102.tar.gz";
    };
    sops-nix = {
      url = "https://flakehub.com/f/Mic92/sops-nix/0.1.887.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    { self
    , nixpkgs
    , flake-utils
    , pre-commit-hooks
    , ...
    } @ inputs:
    let
      user = "iilak";
      devShell = system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          preCommitCheck = self.checks.${system}.pre-commit-check;
        in
        {
          default = with pkgs;
            mkShell {
              inherit (preCommitCheck) shellHook;
              buildInputs = preCommitCheck.enabledPackages;
              nativeBuildInputs = with pkgs; [ bashInteractive git ];
            };
        };
    in
    flake-utils.lib.eachDefaultSystem
      (system:
      {
        apps.default = {
          meta = {
            description = "Shell script to switch to next generation, based on hostname.";
            mainProgram = "build-switch";
          };
          type = "app";
          program = "${self}/apps/build-switch";
        };

        checks = {
          pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              nixpkgs-fmt.enable = true;
            };
          };
        };

        devShells = devShell system;
      }
      ) //
    {
      darwinConfigurations = {
        macbook = import ./hosts/macbook/nix-darwin.nix {
          inherit inputs user;
        };
      };

      homeConfigurations = {
        mxw-dalco02 = import ./hosts/mxw-dalco02/home-manager.nix {
          inherit nixpkgs inputs;
        };
      };

      nixosConfigurations = {
        eiger = import ./hosts/eiger/nixos.nix {
          inherit nixpkgs inputs;
        };
        test = import ./hosts/test/nixos.nix {
          inherit nixpkgs inputs;
        };
      };
    };
}
