let
  mod = import ../modules/shared/global_variables/nfs-utils.nix {
    lib = import <nixpkgs/lib>;
  };

  serviceToUserMap = {
    serviceA = {
      uid = 1000;
      gid = 100;
    };
  };

  serviceDataA = {
    base = "/srv/data";
    allowedIpRange = [
      "10.0.0.1"
      "10.0.0.2"
    ];
  };
in
{
  testExportFormatting = {
    expr = mod.config.mkNfsExport "serviceA" serviceDataA serviceToUserMap;
    expected = ''
      /srv/data 10.0.0.1(rw,fsid=1000,anonuid=1000,anongid=100,no_subtree_check)
      /srv/data 10.0.0.2(rw,fsid=1000,anonuid=1000,anongid=100,no_subtree_check)
    '';
  };
}
