{ config
, lib
, pkgs
, ...
}:
let
  sharedModules = map
    (
      fileName:
      import ./programs/${fileName} { inherit config pkgs lib; }
    )
    (lib.filter (name: lib.hasSuffix ".nix" name) (builtins.attrNames (builtins.readDir ./programs)));
in
{
  imports = sharedModules;
}
