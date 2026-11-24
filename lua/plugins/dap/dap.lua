-- Core DAP setup: adapter, launch configurations and breakpoint signs.
-- Keymaps and the debug UI come from LazyVim's `dap.core` extra.

local sys = {}
sys.platform = vim.g.os.sysname
sys.machine = vim.g.os.machine
sys.exeExt = ""

if sys.platform == "Windows_NT" then
    sys.platform = "windows"
    sys.exeExt = ".exe"
elseif sys.platform == "Darwin" then
    sys.platform = "macosx"
else
    sys.platform = "linux"
end

if sys.machine == "x86_64" or sys.machine == "AMD64" then
    sys.machine = "x86_64"
elseif sys.machine == "i686" or sys.machine == "i386" then
    sys.machine = "i386"
else
    sys.machine = "arm64"
end

-- 输入 unicode 的方法：ctrl + v + u 再输入 unicode 码
-- 可在 https://www.nerdfonts.com/cheat-sheet 查询想要的字符
local dap_breakpoint_color = {
    breakpoint = {
        ctermbg = 0,
        fg = "#993939",
        bg = "#31353f",
    },
    logpoint = {
        ctermbg = 0,
        fg = "#61afef",
        bg = "#31353f",
    },
    stopped = {
        ctermbg = 0,
        fg = "#98c379",
        bg = "#31353f",
    },
}

vim.api.nvim_set_hl(0, "DapBreakpoint", dap_breakpoint_color.breakpoint)
vim.api.nvim_set_hl(0, "DapLogPoint", dap_breakpoint_color.logpoint)
vim.api.nvim_set_hl(0, "DapStopped", dap_breakpoint_color.stopped)

local dap_breakpoint = {
    error = {
        text = "",
        texthl = "DapBreakpoint",
        linehl = "DapBreakpoint",
        numhl = "DapBreakpoint",
    },
    condition = {
        text = "",
        texthl = "DapBreakpoint",
        linehl = "DapBreakpoint",
        numhl = "DapBreakpoint",
    },
    rejected = {
        text = "",
        texthl = "DapBreakpoint",
        linehl = "DapBreakpoint",
        numhl = "DapBreakpoint",
    },
    logpoint = {
        text = "",
        texthl = "DapLogPoint",
        linehl = "DapLogPoint",
        numhl = "DapLogPoint",
    },
    stopped = {
        text = "",
        texthl = "DapStopped",
        linehl = "DapStopped",
        numhl = "DapStopped",
    },
}

vim.fn.sign_define("DapBreakpoint", dap_breakpoint.error)
vim.fn.sign_define("DapBreakpointCondition", dap_breakpoint.condition)
vim.fn.sign_define("DapBreakpointRejected", dap_breakpoint.rejected)
vim.fn.sign_define("DapLogPoint", dap_breakpoint.logpoint)
vim.fn.sign_define("DapStopped", dap_breakpoint.stopped)

return {
    {
        "mfussenegger/nvim-dap",
        event = "VeryLazy",
        config = function()
            local dap = require("dap")

            dap.adapters.lldb = {
                type = "executable",
                command = "lldb-dap",
                name = "lldb",
            }

            dap.configurations.cpp = {
                {
                    name = "Debug C/C++",
                    type = "lldb",
                    request = "launch",
                    program = function()
                        return "${workspaceFolder}/build/"
                            .. sys.platform
                            .. "/"
                            .. sys.machine
                            .. "/debug/${fileBasenameNoExtension}"
                            .. sys.exeExt
                    end,
                    cwd = "${workspaceFolder}",
                    stopOnEntry = false,
                    args = {},
                    -- runInTerminal = false, -- see :h yama/ptrace_scope
                },
            }
            dap.configurations.c = dap.configurations.cpp

            dap.configurations.rust = {
                {
                    name = "Debug Rust",
                    type = "lldb",
                    request = "launch",
                    program = function()
                        return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/target/debug/", "file")
                    end,
                    cwd = "${workspaceFolder}",
                    stopOnEntry = false,
                    args = {},
                },
            }
        end,
    },
    {
        -- lldb-dap is configured above; do not auto-install codelldb as well.
        "jay-babu/mason-nvim-dap.nvim",
        optional = true,
        opts = { automatic_installation = false },
    },
}
