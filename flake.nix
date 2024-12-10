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
    , darwin
    , nix-homebrew
    , homebrew-bundle
    , homebrew-core
    , homebrew-cask
    , home-manager
    , disko
    , nixpkgs
    , nixvim
    , flake-utils
    , pre-commit-hooks
    ,
    } @ inputs:
    let
      user = "iilak";
      linuxSystems = [ "x86_64-linux" "aarch64-linux" ];
      darwinSystems = [ "x86_64-darwin" "aarch64-darwin" ];

      forAllSystems = f: nixpkgs.lib.genAttrs (linuxSystems ++ darwinSystems) f;
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
      mkApp = scriptName: targetSystem: system: {
        type = "app";
        program = "${(nixpkgs.legacyPackages.${system}.writeScriptBin scriptName ''
        #!/usr/bin/env bash
        PATH=${nixpkgs.legacyPackages.${system}.git}/bin:$PATH
        echo "Running ${scriptName} for ${targetSystem}/${system}"
        exec ${self}/apps/${scriptName} ${targetSystem} ${system}
      '')}/bin/${scriptName}";
      };
      mkLinuxApps = system: {
        "work" = mkApp "build-switch" "work" system;
      };
      mkDarwinApps = system: {
        "macbook" = mkApp "build-switch" "macbook" system;
      };
    in
    {
      checks = forAllSystems (system: {
        pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            nixpkgs-fmt.enable = true;
          };
        };
      });

      devShells = forAllSystems devShell;
      apps = nixpkgs.lib.genAttrs linuxSystems mkLinuxApps // nixpkgs.lib.genAttrs darwinSystems mkDarwinApps;

      darwinConfigurations = {
        macbook = import ./hosts/macbook/nix-darwin.nix {
          inherit inputs user;
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
      homeConfigurations = {
        mxw-dalco02 = import ./hosts/workstation/home-manager.nix {
          inherit nixpkgs inputs;
        };
      };
    };
}
