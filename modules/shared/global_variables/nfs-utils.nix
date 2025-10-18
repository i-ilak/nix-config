{
  lib,
  ...
}:
{
  options.mkNfsExport = lib.mkOption {
    type = lib.types.anything;
    default = { };
    description = "Function to make setup of NFS share easier";
  };
  config = {
    mkNfsExport =
      service: serviceData: serviceToUserMap:
      let
        serviceConfig = serviceToUserMap.${service};
        opts = "rw,fsid=${toString serviceConfig.uid},anonuid=${toString serviceConfig.uid},anongid=${toString serviceConfig.gid},no_subtree_check";
        fullExports = map (ip: "${serviceData.base} ${ip}(${opts})") serviceData.allowedIpRange;
      in
      (lib.concatStringsSep "\n" fullExports) + "\n";
  };

}
