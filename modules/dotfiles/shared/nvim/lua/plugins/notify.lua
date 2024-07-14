
local notify_local = require("notify")
notify_local.setup({
    background_colour = "#000000"
})
vim.notify = notify_local
