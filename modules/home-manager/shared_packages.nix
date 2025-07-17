{
  pkgs,
  nixvim,
  ...
}:
let
  cli_tools = with pkgs; [
    fd # `find` alternative
    bat # is better than `cat`
    eza # Alternative to `ls`
    sd # More intuitive `sed`
    procs # Alternative to `ps`
    ripgrep # Fast and intuitive `grep`
    dust # Nicer version of `du`
    tealdeer # Show examples for executables from man pages
    bandwhich # Show network utilization
    grex # Create regex expression from provided examples
    delta # Better `diff` and `git diff` view
  ];

  developer_tools = with pkgs; [
    uv
    just
    docker
    ninja
    rustc
    cargo
    nixvim.packages.${pkgs.system}.default
  ];

  shared_packages = cli_tools ++ developer_tools;
in
shared_packages
