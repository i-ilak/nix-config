{ pkgs
, inputs
, ...
}:
let
  userName = "utm";
  homeDir = "/home/${userName}";
in
{
  home.username = userName;
  home.homeDirectory = homeDir;
  home.packages = [
    inputs.nixvim.packages.${pkgs.system}.default
  ];

  programs.home-manager.enable = true;

  home.stateVersion = "24.11";
}
