_:
let
  sharedFiles = import ../../modules/shared/files.nix { };
  additionalFiles = { };
  file = sharedFiles // additionalFiles;
in
file
