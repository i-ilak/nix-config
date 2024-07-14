vim.g.mapleader = '\\'
vim.g.maplocalleader = "\\"

local opts = { silent = true, noremap = true }

-- General movements
vim.keymap.set("", "ß", "$", opts) -- Move to end of line
vim.keymap.set("", "Y", "y$", opts) -- Copyt until end of line
vim.keymap.set("", "ä", "za", opts) -- Fold/Unfold at current line
vim.keymap.set("", "Ä", "zR", opts) -- Fold/Unfold entire file

-- Delete/change up to next )
vim.keymap.set("n", "d)", "d])") -- Delete up to next
vim.keymap.set("n", "c)", "c])") -- Change up to next
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv") -- Move selected lines one down 
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv") -- Move selected lines one up 
vim.keymap.set("v", "<", "<gv") -- Indent selected lines by one tab
vim.keymap.set("v", ">", ">gv") -- Unindent selected lines by one tab

-- Spell checking
vim.keymap.set("n", "ns", "]s") -- Check spelling front 
vim.keymap.set("n", "ps", "[s") -- Check spelling back

-- Save and quit
vim.keymap.set("n", "s", ":w<CR>", opts) -- Save file
vim.keymap.set("n", "Q", ":qa<CR>", opts) -- Quit
vim.keymap.set("n", "<leader>x", ':bd<CR>', opts) -- Close and delete current buffer

-- Window Movement
vim.keymap.set("n", "<C-Left>", "<C-w>h", opts) -- Move to left window
vim.keymap.set("n", "<C-Down>", "<C-w>j", opts) -- Move to lower window
vim.keymap.set("n", "<C-Up>", "<C-w>k", opts) -- Move to upper window
vim.keymap.set("n", "<C-Right>", "<C-w>l", opts) -- Move to right window

-- Telescope
vim.keymap.set("n", "<leader>fg", ':lua require("telescope")<CR> <cmd>Telescope live_grep<cr>', opts) -- Live grep
vim.keymap.set("n", "<leader>ff", ':lua require("telescope")<CR> <cmd>Telescope find_files<cr>', opts) -- Find file
vim.keymap.set("n", "<leader>fb", ':lua require("telescope")<CR> <cmd>Telescope buffers<cr>', opts) -- Search buffers
vim.keymap.set("n", "<leader>fh", ':lua require("telescope")<CR> <cmd>Telescope help_tags<cr>', opts) -- Help tags

-- Bufferline
vim.keymap.set("n", "<TAB>", ":BufferLineCycleNext<CR>", opts) -- Go to next Tab
vim.keymap.set("n", "<S-TAB>", ":BufferLineCyclePrev<CR>", opts) -- Go to previous Tab

-- nnn
vim.keymap.set("n", "<leader>n", ':lua require("nnn")<CR> :NnnPicker<CR>', opts) -- Open file picker
vim.keymap.set("n", "<leader>N", ':lua require("nnn")<CR> :NnnExplorer<CR>', opts) -- Open file explorer on the right

-- Leap
vim.keymap.set("n", "f", ':lua require("leap")<CR> <Plug>(leap-forward)', opts) -- Leap forward
vim.keymap.set("n", "F", ':lua require("leap")<CR> <Plug>(leap-backward)', opts) -- Leap backward

-- nvim-spider (w,e,b replacement)
vim.keymap.set({ "n", "o", "x" }, "w", "<cmd>lua require('spider').motion('w')<CR>", opts) --  
vim.keymap.set({ "n", "o", "x" }, "e", "<cmd>lua require('spider').motion('e')<CR>", opts) -- 
vim.keymap.set({ "n", "o", "x" }, "b", "<cmd>lua require('spider').motion('b')<CR>", opts) -- 
vim.keymap.set({ "n", "o", "x" }, "ge", "<cmd>lua require('spider').motion('ge')<CR>", opts) -- 

-- Comment
vim.keymap.set("n", "<leader>c", "<cmd> :lua require('Comment.api').toggle.linewise.current()<CR>", opts) -- Comment line
vim.keymap.set("v", "<leader>c", "<esc><cmd> :lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>", opts) -- Comment selection

-- EasyAlign
vim.keymap.set("v", "<leader>a", ":EasyAlign<CR>", opts) -- Algin selection

-- CMake
vim.keymap.set("n", "<F6>", ":CMakeGenerate<CR>", opts) -- Run cmake -S . -B Debug/Release
vim.keymap.set("n", "<F7>", ":CMakeBuild<CR>", opts) -- Run cmake --build -j6 Debug/Release

-- LSP
function my_references()
  require("telescope.builtin").lsp_references {
    layout_strategy = "horizontal",
    layout_config = {
      width = 0.8,
      height = 0.9,
      prompt_position = "bottom",
    },
    sorting_strategy = "descending",
    ignore_filename = false,
  }
end

vim.keymap.set("n", "gD", function() vim.lsp.buf.declaration() end, opts) -- Got to declaration
vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts) -- Got to definition
vim.keymap.set("n", "ga", function() vim.lsp.buf.code_action() end, opts) -- Show code actions
vim.keymap.set("n", "<leader>f", function() vim.lsp.buf.format { async = false } end, opts) -- Format file
vim.keymap.set("n", "<leader>k", function() vim.diagnostic.open_float({ scope = "line" }) end, opts) -- Open float
vim.keymap.set("n", "fu", function() my_references() end, opts) -- Find references/usage
vim.keymap.set("n", "rr", function() vim.lsp.buf.rename() end, opts) -- Rename all instances
vim.keymap.set("n", "ko", ":ClangdSwitchSourceHeader<CR>", opts) -- Switch between header and source file 
vim.keymap.set("n", "koh", ":ClangdSwitchSourceHeaderSplit<CR>", opts) -- Switch between header and source file 
vim.keymap.set("n", "kov", ":ClangdSwitchSourceHeaderVSplit<CR>", opts) -- Switch between header and source file 
vim.keymap.set("n", "<leader>`", function() vim.diagnostic.open_float() end, opts) -- Toggle diagnostics window


-- Dap
-- This function wraps the standard dap.continue call and reads the correct launch.json file 
local my_continue = function()
    if vim.fn.filereadable(".vscode/launch.json") then
        require("dap.ext.vscode").load_launchjs(nil, { cppdbg = { "c", "cpp" } })
    end
    require("dap").continue()
end

vim.keymap.set("n", "<leader>q", function() require "dap".close() end, opts) -- Close debugger
vim.keymap.set("n", "<leader>d", function() require "dapui".toggle({ reset = true }) end, opts) -- Open/Close debug Ui
vim.keymap.set("n", "<leader>t", function() require "dap".terminate() end, opts) -- Terminate debugging session
vim.keymap.set("n", "<leader>e", function() require("dapui").eval() end, opts) -- Evaluate expression
vim.keymap.set("n", "<F5>", function() my_continue() end, opts) -- Start/continue
vim.keymap.set("n", "<F9>", function() require "dap".toggle_breakpoint() end, opts) -- Toggle breakpoint
vim.keymap.set("n", "<F10>", function() require "dap".step_over() end, opts) -- Step over
vim.keymap.set("n", "<F11>", function() require "dap".step_into() end, opts) -- Step into
vim.keymap.set("n", "<F12>", function() require("dap").step_out() end, opts) -- Step out

-- BlameToggle
vim.keymap.set("n", "bt", ":BlameToggle<CR>", opts) -- Step out

-- Trailblazer
vim.keymap.set("n", "m", function() require("plugins.trailblazer").new_mark() end, opts)
vim.keymap.set("n", "<C-l>", function() require("trailblazer").peek_move_previous_up() end, opts)
vim.keymap.set("n", "<C-k>", function() require("trailblazer").peek_move_next_down() end, opts)
vim.keymap.set("n", "<Esc>c", function() require("trailblazer").move_to_trail_mark_cursor() end, opts)
vim.keymap.set("n", "<Esc>b", function() require("trailblazer").track_back() end, opts)
vim.keymap.set("n", "<Esc>l", function() require("plugins.trailblazer").load_session() end, opts)
vim.keymap.set("n", "<Esc>s", function() require("plugins.trailblazer").save_all_sessions() end, opts)
vim.keymap.set("n", "<Esc>da", function() require("plugins.trailblazer").delete_all_marks() end, opts)
vim.keymap.set("n", "<Esc>ds", function() require("trailblazer").delete_trail_mark_stack(nil, false) end, opts)
vim.keymap.set("n", "<Esc>as", function() require("plugins.trailblazer").add_stack() end, opts)
vim.keymap.set("n", "<Esc>p", function() require("trailblazer").switch_to_previous_trail_mark_stack(nil, false) end, opts)
vim.keymap.set("n", "<Esc>n", function() require("trailblazer").switch_to_next_trail_mark_stack(nil, false) end, opts)
