{
  pkgs,
  ...
}:
{
  fonts = {
    fontDir.enable = true;
    enableGhostscriptFonts = true;
    packages = with pkgs; [
      meslo-lgs-nf
      dejavu_fonts
      jetbrains-mono
      font-awesome
      noto-fonts
      noto-fonts-emoji
    ];
  };
}
