local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

return require("lazy").setup(
    {
        "tpope/vim-dispatch",
        "rafamadriz/friendly-snippets",
        "saadparwaiz1/cmp_luasnip",
        "hrsh7th/cmp-nvim-lua",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-path",
        "junegunn/vim-easy-align",
        {
            "rcarriga/nvim-notify",
            config = function()
                require("plugins.notify")
            end,
        },
        {
            lazy = true,
            event = "BufReadPost",
            'mrded/nvim-lsp-notify',
            config = function()
                require('lsp-notify').setup({})
            end
        },
        {
            event = "BufReadPost",
            "nvim-treesitter/nvim-treesitter",
            build = ":TSUpdate",
            config = function()
                require "plugins.treesitter"
            end,
        },
        {
            "williamboman/mason.nvim",
            config = function()
                require "plugins.mason"
            end,
        },
        {
            "williamboman/mason-lspconfig.nvim",
            config = function()
                require "plugins.mason_lspconfig"
            end,
        },
        {
            event = "BufReadPost",
            "neovim/nvim-lspconfig",
            config = function()
                require "plugins.lspconfig"
            end,
        },
        {
            event = "BufEnter *.rs",
            "simrat39/rust-tools.nvim",
            config = function()
                require "rust-tools".setup()
            end,
        },
        {
            "hrsh7th/nvim-cmp",
            config = function()
                require "plugins.cmp"
            end,
        },
        {
            event = "BufWinEnter",
            "L3MON4D3/LuaSnip",
            dependencies = "onsails/lspkind.nvim",
            run = "make install_jsregexp",
            config = function()
                require "plugins.luasnip"
            end,
        },
        {
            "ray-x/lsp_signature.nvim",
            config = function()
                require "lsp_signature".setup()
            end
        },
        {
            "lukas-reineke/indent-blankline.nvim",
            main = "ibl",
            config = function()
                require "plugins.blankline"
            end,
        },
        {
            "lewis6991/gitsigns.nvim",
            config = function()
                require "gitsigns".setup()
            end
        },
        {
            lazy = true,
            "mfussenegger/nvim-dap",
            config = function()
                require "plugins.dap"
            end,
        },
        {
            event = "BufEnter *.py",
            "mfussenegger/nvim-dap-python",
            config = function()
                require "dap-python".setup("python")
            end,
        },
        {
            lazy = true,
            "rcarriga/nvim-dap-ui",
            dependencies = { "nvim-neotest/nvim-nio" },
            config = function()
                require "plugins.dapui"
            end,
        },
        {
            lazy = true,
            "numToStr/Comment.nvim",
            config = function()
                require "Comment".setup()
            end
        },
        {
            "norcalli/nvim-colorizer.lua",
            config = function()
                require "colorizer".setup()
            end
        },
        {
            lazy = true,
            event = "BufEnter",
            "akinsho/bufferline.nvim",
            dependencies = "kyazdani42/nvim-web-devicons",
            config = function()
                require "plugins.bufferline"
            end
        },
        {
            lazy = true,
            "luukvbaal/nnn.nvim",
            config = function()
                require("nnn").setup()
            end
        },
        {
            "folke/todo-comments.nvim",
            dependencies = "nvim-lua/plenary.nvim",
            config = function()
                require "todo-comments".setup()
            end
        },
        {
            lazy = true,
            "ggandor/leap.nvim",
        },
        {
            lazy = true,
            "nvim-telescope/telescope.nvim",
            dependencies = {
                { "nvim-lua/plenary.nvim" },
                -- { "ilyachur/cmake4vim" }
            },
            config = function()
                require("plugins.telescope")
            end
        },
        {
            lazy = true,
            "LeonHeidelbach/trailblazer.nvim",
            config = function()
                require("plugins.trailblazer").init()
            end
        },
        {
            lazy = true,
            "chrisgrieser/nvim-spider"
        },
        {
            priority = 1000,
            "catppuccin/nvim",
            name = "catppuccin",
            build = ":CatppuccinCompile",
            config = function()
                require "plugins.catppuccin"
            end
        },
        {
            lazy = true,
            "sudormrfbin/cheatsheet.nvim",
            dependencies = {
                { 'nvim-telescope/telescope.nvim' },
                { 'nvim-lua/popup.nvim' },
                { 'nvim-lua/plenary.nvim' },
            },
        },
        {
            event = "VeryLazy",
            "nvim-lualine/lualine.nvim",
            config = function()
                require "plugins.lualine"
            end
        },
        {
            "kylechui/nvim-surround",
            version = "*",
            event = "VeryLazy",
            config = function()
                require("nvim-surround").setup({
                    -- Configuration here, or leave empty to use defaults
                })
            end
        },
        {
            lazy = true,
            "dnlhc/glance.nvim"
        },
        -- {
        --     lazy = true,
        --     event = "BufEnter *.{h,hpp,c,cpp}",
        --     "ilyachur/cmake4vim",
        --     config = function()
        --         require "plugins.cmake4vim"
        --     end
        -- },
        -- {
        --     "SantinoKeupp/lualine-cmake4vim.nvim",
        --     dependencies = "ilyachur/cmake4vim"
        -- },
        -- {
        --     lazy = true,
        --     "SantinoKeupp/telescope-cmake4vim.nvim",
        --     dependencies = "nvim-telescope/telescope.nvim"
        -- },
        {
            lazy = true,
            event = "VeryLazy",
            'stevearc/overseer.nvim',
            opts = {},
        },
        {
            lazy = true,
            event = "VeryLazy",
            'akinsho/toggleterm.nvim',
            version = "*",
            config = true
        },
        {
            lazy = true,
            event = "BufEnter *.{h,hpp,c,cpp,txt}",
            'Civitasv/cmake-tools.nvim',
            dependencies = {
                "stevearc/overseer.nvim",
                'akinsho/toggleterm.nvim',
            },
            config = function()
                require "plugins.cmake_tools"
            end
        },
        {
            cond = vim.fn.filereadable(vim.fn.getcwd() .. '/platformio.ini') == 1,
            "normen/vim-pio"
        },
        {
            dir = "/home/iilak/prg/internal/pio.nvim",
            name = "pio.nvim",
            -- config = function()
            --     require('pio.nvim')
            -- end
        },
        {
            lazy = true,
            event = "BufEnter *.md",
            "epwalsh/obsidian.nvim",
            dependencies = {
                "nvim-lua/plenary.nvim",
            },
            -- opts = {
            --     workspaces = {
            --         {
            --             name = "cas_notes",
            --             path = "~/prg/internal/cas/cas_notes",
            --         },
            --     },
            -- },
        },
        {
            lazy = true,
            event = "BufEnter *.{h,hpp,c,cpp}",
            'jedrzejboczar/nvim-dap-cortex-debug',
            dependencies = 'mfussenegger/nvim-dap'
        },
        {
            "zbirenbaum/copilot.lua",
            event = "InsertEnter",
            config = function()
                require("copilot").setup({
                    suggestion = { enabled = false },
                    panel = { enabled = false },
                })
            end,
        },
        {
            "zbirenbaum/copilot-cmp",
            dependencies = { "zbirenbaum/copilot.lua" },
            config = function()
                require("copilot_cmp").setup()
            end
        },
        {
            lazy = true,
            event = "VeryLazy",
            "FabijanZulj/blame.nvim",
            config = function()
                require("blame").setup()
            end
        },
        {
            lazy = true,
            event = "BufEnter *",
            "nvim-treesitter/nvim-treesitter-context",
            dependencies = "nvim-treesitter/nvim-treesitter",
            config = function()
                require("treesitter-context").setup({
                    separator = "—",
                })
            end
        }
    })
