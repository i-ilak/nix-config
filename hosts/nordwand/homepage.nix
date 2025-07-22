_: {
  services.homepage-dashboard = {
    enable = true;
    listenPort = 8082;
    allowedHosts = "127.0.0.1:8082";
    settings = {
      bookmarks = [
        {
          title = "NixOS";
          href = "https://nixos.org";
          description = "Official site";
        }
        {
          title = "Homepage Repo";
          href = "https://github.com/withfig/homepage";
        }
      ];
      services = {
        Weather = {
          href = "/weather";
          description = "Local weather";
        };
      };
    };
  };
}
