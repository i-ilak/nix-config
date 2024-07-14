local servers = require("plugins.lsp_server_list")
local capabilities = vim.lsp.protocol.make_client_capabilities()

capabilities.textDocument.completion.completionItem = {
    documentationFormat = { "markdown", "plaintext" },
    snippetSupport = true,
    prefelectSupport = true,
    insertReplaceSupport = true,
    labelDetailsSupport = true,
    deprecatedSupport = true,
    commitCharactersSupport = true,
    tagSupport = { valueSet = { 1 } },
    resolveSupport = {
        properties = {
            "documentation",
            "detail",
            "additionalTextEdits",
        },
    },
}

local on_attach = function(client, bufnr)
    if client.name == 'ruff_lsp' then
        -- Disable hover in favor of Pyright
        client.server_capabilities.hoverProvider = false
    end
end

vim.g.rust_recommended_style = false

local function switch_source_header_splitcmd(bufnr, splitcmd)
    bufnr = require 'lspconfig'.util.validate_bufnr(bufnr)
    local clangd_client = require 'lspconfig'.util.get_active_client_by_name(bufnr, 'clangd')
    local params = { uri = vim.uri_from_bufnr(bufnr) }
    if clangd_client then
        clangd_client.request("textDocument/switchSourceHeader", params, function(err, result)
            if err then
                error(tostring(err))
            end
            if not result then
                print("Corresponding file can’t be determined")
                return
            end
            vim.api.nvim_command(splitcmd .. " " .. vim.uri_to_fname(result))
        end, bufnr)
    else
        print 'textDocument/switchSourceHeader is not supported by the clangd server active on the current buffer'
    end
end

capabilities.offsetEncoding = { "utf-16" }

for _, lsp in ipairs(servers) do
    if lsp == "clangd" then
        require("lspconfig")[lsp].setup {
            on_attach = on_attach,
            capabilities = capabilities,
            cmd = {
                "clangd",
                "-background-index",
                string.format("-compile-commands-dir=%s", vim.fn.getcwd()),
                "--clang-tidy",
                "--pretty",
                "--query-driver=/opt/homebrew/bin/arm-none-eabi-gcc,/opt/homebrew/bin/arm-none-eabi-g++,/usr/bin/arm-none-eabi-gcc,/usr/bin/arm-none-eabi-g++"
            }, -- Add any necessary command line flags
            filetypes = { "c", "cpp", "objc", "objcpp" },
            root_dir = function(fname)
                return vim.fn.getcwd()
            end,
            settings = {
                file = ".clang-format", -- Specify .clang-format file
            },
            commands = {
                ClangdSwitchSourceHeader = {
                    function() switch_source_header_splitcmd(0, "edit") end,
                    description = "Open source/header in current buffer",
                },
                ClangdSwitchSourceHeaderVSplit = {
                    function() switch_source_header_splitcmd(0, "vsplit") end,
                    description = "Open source/header in a new vsplit",
                },
                ClangdSwitchSourceHeaderSplit = {
                    function() switch_source_header_splitcmd(0, "split") end,
                    description = "Open source/header in a new split",
                }
            }
        }
    elseif lsp == "pyright" then
        require('lspconfig')[lsp].setup {
            settings = {
                pyright = {
                    -- Using Ruff's import organizer
                    disableOrganizeImports = true,
                },
                python = {
                    analysis = {
                        typeCheckMode = "strict"
                    },
                },
            },
        }
    else
        require("lspconfig")[lsp].setup {
            on_attach = on_attach,
            capabilities = capabilities,
        }
    end
end

require("lspconfig")["lua_ls"].setup {
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
        Lua = {
            diagnostics = {
                globals = { "vim", "on_attach" },
            },
        }
    }
}

-- disable virtual_text (inline) diagnostics and use floating window
-- format the message such that it shows source, message and
-- the error code. Show the message with <space>e
vim.diagnostic.config({
    virtual_text = false,
    signs = true,
    float = {
        border = "single",
        format = function(diagnostic)
            return string.format(
                "%s (%s) [%s]",
                diagnostic.message,
                diagnostic.source,
                diagnostic.code or diagnostic.user_data.lsp.code
            )
        end,
    },
})
