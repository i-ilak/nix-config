{
  pkgs,
  lib,
  ...
}:
let
  isNixOS = pkgs.stdenv.isLinux && builtins.pathExists "/etc/nixos";
in
{
  programs.helix = {
    extraPackages = with pkgs; [ nixd ];
    languages = {
      language = [
        {
          name = "nix";
          auto-format = true;
          formatter.command = "${pkgs.nixfmt-rfc-style}/bin/nixfmt";
          language-servers = [ "nixd" ];
        }
      ];

      language-server.nixd = {
        command = "nixd";
        args = [ "--semantic-tokens=true" ];
        config.nixd = {
          formatting.command = [ "${lib.getExe pkgs.nixfmt-rfc-style}" ];
        }
        // lib.optionalAttrs isNixOS (
          let
            myFlake = builtins.getFlake "/etc/nixos";
            nixosHost = myFlake.nixosConfigurations.${builtins.getEnv "HOSTNAME"};
            nixosOpts = nixosHost.options;
          in
          {
            nixpkgs.expr = "import ${myFlake}.inputs.nixpkgs { }";
            options = {
              nixos.expr = nixosOpts;
              home-manager.expr = "${nixosOpts}.home-manager.users.type.getSubOptions []";
            };
          }
        );
      };
    };
  };
}
