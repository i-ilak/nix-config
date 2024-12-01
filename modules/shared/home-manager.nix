{ config
, lib
, pkgs
, user
, ...
}:
let
  programFiles =
    lib.filter
      (name: lib.hasSuffix ".nix" name)
      (builtins.attrNames (builtins.readDir ./programs));

  sharedModules =
    lib.genAttrs
      (map (name: lib.strings.removeSuffix ".nix" name) programFiles)
      (
        name:
        let
          importedModule = import ./programs/${name + ".nix"} { inherit config pkgs lib user; };
        in
        if lib.isAttrs importedModule && lib.hasAttr name importedModule
        then importedModule.${name} # Extract the attribute matching the file name
        else importedModule # Use the module directly if no nesting
      );
in
sharedModules
