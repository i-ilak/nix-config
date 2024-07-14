require("telescope").setup(
    {
        defaults = {
            file_ignore_patterns = { "^./.git/.*", "^build/.*", "^CMakeFiles/.*", "^.*.ui", "^edit_cache/.*" },
            mappings = {
                i = {
                    ["<Esc>"] = "close",
                    ["<C-c>"] = false,
                }
            }
        }
    }
)
-- require('telescope').load_extension('cmake4vim')
