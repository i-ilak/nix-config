local dap = require('dap')
local dap_cortex_debug = require('dap-cortex-debug')

dap.adapters.cppdbg = {
    type = 'executable',
    command = 'lldb-vscode-14', -- adjust as needed
    name = "cppdbg",
    options = { detached = false },
}

dap_cortex_debug.setup {
    debug = true,
    extension_path = nil,
    lib_extension = nil,
    node_path = '/opt/homebrew/bin/node',
    dapui_rtt = true,
    dap_vscode_filetypes = { 'c', 'cpp' },
}

dap.configurations.python = {
    {
        name = "Launch",
        type = "lldb",
        request = "launch",
        program = '${file}',
    }
}

dap.configurations.c = {
    {
        name = "LLDB",
        type = "lldb",
        request = "launch",
        program = function()
            local cwd = vim.fn.getcwd()
            return cwd .. '/bin/debug'
        end,
        cwd = '${workspaceFolder}',
        stopOnEntry = false,
        args = {},
        runInTerminal = false,
        postRunCommands = { 'process handle -p true -s false -n false SIGWINCH' }
    }
}

dap.configurations.cpp = dap.configurations.c
dap.configurations.objc = dap.configurations.c
dap.configurations.rust = dap.configurations.cpp
