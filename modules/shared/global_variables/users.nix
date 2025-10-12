{
  lib,
  ...
}:
let
  baseId = 10000;
  serviceOffsets = {
    paperless = 1;
    jellyfin = 2;
    ytdl-sub = 3;
    immich = 100;
    navidrome = 101;
  };
  services = lib.mapAttrs (_: offset: {
    uid = baseId + offset;
    gid = baseId + offset;
  }) serviceOffsets;
  mkServiceConfig =
    name:
    { uid, gid }:
    {
      users.users.${name} = {
        isSystem = true;
        inherit uid;
        group = name;
      };
      users.groups.${name} = {
        inherit gid;
      };
    };
in
{
  options.nfsUtils = lib.mkOption {
    type = lib.types.attrs;
    default = { };
    description = "Functions and variable utils to make setup of NFS share easier";
  };
  config = {
    nfsUtils = {
      serviceToUserMap = services;
      mkUserAndGroupForService = mkServiceConfig;
    };
  };
}
