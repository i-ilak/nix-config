{
  description = "General Purpose Configuration for macOS and NixOS";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    home-manager = {
      url = "github:nix-community/home-manager";
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
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:i-ilak/nixvim-config";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
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
        # Add the default app
        apps.default = {
          meta = {
            description = "Shell script to switch to next generation, based on hostname.";
            mainProgram = "build-switch";
          };
          type = "app";
          program = "${self}/apps/build-switch";
        };

        # Keep your existing checks
        checks = {
          pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              nixpkgs-fmt.enable = true;
            };
          };
        };

        # Keep your existing devShells
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
        utm = import ./hosts/workstation/home-manager.nix {
          inherit nixpkgs inputs;
        };
      };

      # nixosConfigurations = nixpkgs.lib.genAttrs linuxSystems (
      #   system:
      #     nixpkgs.lib.nixosSystem {
      #       inherit system;
      #       specialArgs = {inherit inputs;};
      #       modules = [
      #         home-manager.nixosModules.home-manager
      #         {
      #           home-manager = {
      #             useGlobalPkgs = true;
      #             useUserPackages = true;
      #             users.${user} = import ./modules/nixos/home-manager.nix;
      #           };
      #         }
      #         ./hosts/nixos
      #       ];
      #     }
      # );
    };
}
