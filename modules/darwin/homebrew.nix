{ pkgs
, ...
}:
{
  homebrew = {
    enable = true;
    casks = pkgs.callPackage ./casks.nix { };

    taps = [
      "nikitabobko/tap"
    ];

    masApps = {
      "strongbox" = 897283731;
      "reader" = 1529448980;
      "whatsapp" = 310633997;
    };
  };

}
