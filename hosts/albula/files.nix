_:
let
  sharedFiles = { };
  additionalFiles = { };
  file = sharedFiles // additionalFiles;
in
file
