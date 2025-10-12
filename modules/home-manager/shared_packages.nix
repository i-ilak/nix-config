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
    comma # Run easily things from nixpkgs without first creating a shell
  ];

  developer_tools = with pkgs; [
    uv
    just
    docker
    ninja
    rustc
    cargo
    nixvim.packages.${pkgs.system}.default
    llvmPackages_20.clang-unwrapped
  ];

  shared_packages = cli_tools ++ developer_tools;
in
shared_packages
