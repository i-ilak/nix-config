local servers = require("plugins.lsp_server_list")
local options = {
  ensure_installed = servers
}

require("mason-lspconfig").setup(options)
