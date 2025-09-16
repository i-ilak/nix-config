{
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    # inputs.catppuccin.homeModules.catppuccin
    inputs.sops-nix.homeModules.sops
    ./additional_config_parameters.nix
    ../../modules/home-manager/i3.nix
    ../../modules/home-manager/programs/git.nix
    ../../modules/home-manager/programs/rofi.nix
    ../../modules/home-manager/programs/fish.nix
    ../../modules/home-manager/programs/direnv.nix
    ../../modules/home-manager/programs/alacritty.nix
    ../../modules/home-manager/programs/fzf.nix
    ../../modules/home-manager/programs/i3_status_rust.nix
    ../../modules/home-manager/programs/polybar.nix
    ../../modules/home-manager/programs/ghostty.nix
  ];

  sops =
    let
      secretspath = builtins.toString inputs.nix-secrets;
    in
    {
      secrets = {
        "ssh_git_signing_key/public" = {
          sopsFile = "${secretspath}/secrets/shared.yaml";
          format = "yaml";
        };
      };
      age = {
        sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      };
    };

  home = {
    enableNixpkgsReleaseCheck = false;
    packages = pkgs.callPackage ./packages.nix { inherit inputs; };
    file = import ./files.nix { };
    stateVersion = "25.05";
  };

  # catppuccin = {
  #   flavor = "mocha";
  #   enable = true;
  # };
}
