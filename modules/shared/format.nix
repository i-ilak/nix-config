_:
{
  projectRootFile = "flake.nix";
  programs = {
    nixpkgs-fmt.enable = true;
    yamlfmt.enable = true;
  };
  settings.global.excludes = [
    "*.md"
    "LICENSE"
    ".envrc"
  ];
}
