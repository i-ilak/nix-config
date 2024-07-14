local options = {
  ensure_installed = {
    "lua",
    "vim",
    "c",
    "cpp",
    "python",
    "rust",
    "markdown",
    "markdown_inline"
  },
  highlight = {
    enable = true,
    use_languagetree = true,
  },
}

require("nvim-treesitter.configs").setup(options)
