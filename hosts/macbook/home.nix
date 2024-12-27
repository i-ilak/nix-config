{ config
, pkgs
, lib
, ...
}:
let
  inherit (config.sharedVariables) user;
  sharedFiles = import ../../modules/shared/files.nix {
    inherit config pkgs lib;
  };
  additionalFiles = import ../../modules/darwin/files.nix { inherit user config pkgs; };
in
{
  home-manager = {
    useGlobalPkgs = true;
    users.${user} =
      { pkgs
      , lib
      , config
      , ...
      }: {
        imports = [
          ./additional_config_parameters.nix
          ../../modules/shared/programs/git.nix
          ../../modules/shared/programs/zsh.nix
          ../../modules/shared/programs/direnv.nix
          ../../modules/shared/programs/alacritty.nix
          # ../../modules/shared/programs/ssh_private.nix
        ];

        home = {
          enableNixpkgsReleaseCheck = false;
          packages = pkgs.callPackage ./packages.nix { };
          file = lib.mkMerge [
            sharedFiles
            additionalFiles
          ];

          stateVersion = "24.05";
        };

        # Marked broken Oct 20, 2022 check later to remove this
        # https://github.com/nix-community/home-manager/issues/3344
        manual.manpages.enable = false;
      };
  };
}
