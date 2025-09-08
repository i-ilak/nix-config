{
  pkgs,
  inputs,
  config,
  ...
}:
let
  secretspath = builtins.toString inputs.nix-secrets;
  inherit (config.sharedVariables) homeDir;
in
{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
    inputs.catppuccin.homeModules.catppuccin
    ./additional_config_parameters.nix
    ./ssh.nix
    ../../modules/home-manager/programs/git.nix
    ../../modules/home-manager/programs/zsh.nix
    ../../modules/home-manager/programs/fzf.nix
    ../../modules/home-manager/programs/fish.nix
    ../../modules/home-manager/programs/direnv.nix
    ../../modules/home-manager/programs/alacritty.nix
  ];

  sops = {
    defaultSopsFile = "${secretspath}/secrets/shared.yaml";
    age = {
      keyFile = "${homeDir}/Library/Application Support/sops/age/keys.txt";
    };
    secrets."ssh_git_signing_key/public" = { };
  };

  home = {
    enableNixpkgsReleaseCheck = false;
    packages = pkgs.callPackage ./packages.nix { inherit inputs; };
    file = import ./files.nix { };
    stateVersion = "25.05";
  };

  catppuccin = {
    flavor = "mocha";
    enable = true; # Enables it for all supported tools
  };
}
