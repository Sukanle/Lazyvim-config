local sys = {}
sys.platform = vim.g.os.sysname
sys.machine = vim.g.os.machine
sys.exeExt = ""

if sys.platform == "Window_NT" then
    sys.platform = "window"
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

-- 设置调试相关的字符和颜色
local dap_breakpoint_color = {
    breakpoint = {
        ctermbg = 0,
        fg = "#993939",
        bg = "#31353f",
    },
    logpoing = {
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
vim.api.nvim_set_hl(0, "DapLogPoint", dap_breakpoint_color.logpoing)
vim.api.nvim_set_hl(0, "DapStopped", dap_breakpoint_color.stopped)

-- 输入unicode的方法：ctrl + v + u 再输入unicode码
-- 可在https://www.nerdfonts.com/cheat-sheet查询想要的字符
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
-- end dap
return {
    {
        "mfussenegger/nvim-dap",
        event = "VeryLazy",
        keys = function()
            -- 🌍 语言检测逻辑
            local lang = vim.env.LC_ALL or vim.env.LANG or ""
            local is_zh = lang:match("zh_CN") or lang:match("zh_TW") or lang:match("zh_HK")

            -- 定义描述映射表
            local desc = {
                run_args = is_zh and "带参数运行" or "Run with Args",
                toggle_bp = is_zh and "切换断点" or "Toggle Breakpoint",
                cond_bp = is_zh and "条件断点" or "Breakpoint Condition",
                continue = is_zh and "运行/继续" or "Run/Continue",
                run_cursor = is_zh and "运行到光标" or "Run to Cursor",
                eval = is_zh and "计算表达式" or "Eval",
                goto_line = is_zh and "跳转行 (不执行)" or "Go to Line (No Execute)",
                step_into = is_zh and "单步进入" or "Step Into",
                down = is_zh and "向下查看" or "Down",
                up = is_zh and "向上查看" or "Up",
                run_last = is_zh and "重复上次运行" or "Run Last",
                step_out = is_zh and "单步跳出" or "Step Out",
                step_over = is_zh and "单步跳过" or "Step Over",
                pause = is_zh and "暂停" or "Pause",
                toggle_repl = is_zh and "切换 REPL" or "Toggle REPL",
                session = is_zh and "会话信息" or "Session",
                terminate = is_zh and "终止调试" or "Terminate",
                dap_ui = is_zh and "调试界面" or "Dap UI",
                widgets = is_zh and "调试组件" or "Widgets",
                profiler = is_zh and "性能分析" or "+profiler",
            }

            -- 返回按键配置
            return {
                {
                    "<leader>da",
                    function()
                        require("dap").continue({
                            before = function()
                                vim.fn.input("Args: ")
                            end,
                        })
                    end,
                    desc = "a ➜ 󰃤 " .. desc.run_args,
                },
                {
                    "<leader>db",
                    function()
                        require("dap").toggle_breakpoint()
                    end,
                    desc = "b ➜  " .. desc.toggle_bp,
                },
                {
                    "<leader>dB",
                    function()
                        require("dap").set_breakpoint(vim.fn.input("断点条件: "))
                    end,
                    desc = "B ➜ 󰃤 " .. desc.cond_bp,
                },
                {
                    "<leader>dc",
                    function()
                        require("dap").continue()
                    end,
                    desc = "c ➜ 󰃤 " .. desc.continue,
                },
                {
                    "<leader>dC",
                    function()
                        require("dap").run_to_cursor()
                    end,
                    desc = "C ➜ 󰃤 " .. desc.run_cursor,
                },
                {
                    "<leader>de",
                    function()
                        require("dap").eval(vim.fn.input("表达式: "))
                    end,
                    mode = { "n", "v" },
                    desc = "e ➜ 󰃤 " .. desc.eval,
                },
                {
                    "<leader>dg",
                    function()
                        require("dap").goto_(vim.fn.input("行号: "))
                    end,
                    desc = "g ➜ 󰃤 " .. desc.goto_line,
                },
                {
                    "<leader>di",
                    function()
                        require("dap").step_into()
                    end,
                    desc = "i ➜ 󰃤 " .. desc.step_into,
                },
                {
                    "<leader>dj",
                    function()
                        require("dap.ui").down()
                    end,
                    desc = "j ➜ 󰃤 " .. desc.down,
                }, -- 需确认 dap.ui 是否存在，通常是切换焦点
                {
                    "<leader>dk",
                    function()
                        require("dap.ui").up()
                    end,
                    desc = "k ➜ 󰃤 " .. desc.up,
                },
                {
                    "<leader>dl",
                    function()
                        require("dap").run_last()
                    end,
                    desc = "l ➜ 󰃤 " .. desc.run_last,
                },
                {
                    "<leader>do",
                    function()
                        require("dap").step_out()
                    end,
                    desc = "o ➜ 󰃤 " .. desc.step_out,
                },
                {
                    "<leader>dO",
                    function()
                        require("dap").step_over()
                    end,
                    desc = "O ➜ 󰃤 " .. desc.step_over,
                },
                {
                    "<leader>dP",
                    function()
                        require("dap").pause()
                    end,
                    desc = "P ➜ 󰃤 " .. desc.pause,
                },
                {
                    "<leader>dr",
                    function()
                        require("dap").repl.toggle()
                    end,
                    desc = "r ➜  " .. desc.toggle_repl,
                },
                {
                    "<leader>ds",
                    function()
                        require("dap").session()
                    end,
                    desc = "s ➜  " .. desc.session,
                },
                {
                    "<leader>dt",
                    function()
                        require("dap").terminate()
                    end,
                    desc = "t ➜ 󰃤 " .. desc.terminate,
                },
                {
                    "<leader>du",
                    function()
                        require("dapui").toggle()
                    end,
                    desc = "u ➜ 󰙵 " .. desc.dap_ui,
                },
                {
                    "<leader>dw",
                    function()
                        require("dap.ui.widgets").hover()
                    end,
                    desc = "w ➜ 󰃤 " .. desc.widgets,
                },
                {
                    "<leader>dp",
                    function()
                        require("dap").select_profile()
                    end,
                    desc = "p ➜ ⚡ " .. desc.profiler,
                }, -- 假设是选择配置或 profiler
            }
        end,
        config = function()
            local dap = require("dap")
            dap.adapters.lldb = {
                type = "executable",
                command = "lldb-dap", -- adjust as needed, must be absolute path
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

                    -- 💀
                    -- if you change `runInTerminal` to true, you might need to change the yama/ptrace_scope setting:
                    --
                    --    echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope
                    --
                    -- Otherwise you might get the following error:
                    --
                    --    Error on launch: Failed to attach to the target process
                    --
                    -- But you should be aware of the implications:
                    -- https://www.kernel.org/doc/html/latest/admin-guide/LSM/Yama.html
                    -- runInTerminal = false,
                },
            }

            dap.configurations.c = dap.configurations.cpp
            dap.configurations.rust = dap.configurations.cpp
        end,
    },
    {
        "rcarriga/nvim-dap-ui",
        dependencies = {
            "mfussenegger/nvim-dap",
        },
        opts = function()
            local dap, dapui = require("dap"), require("dapui")

            -- ✅ 正确：在调试会话初始化完成后打开 UI
            dap.listeners.after.event_initialized["dapui_config"] = function()
                dapui.open()
            end

            -- ✅ 在会话终止或退出时关闭 UI
            dap.listeners.before.event_terminated["dapui_config"] = function()
                dapui.close()
            end
            dap.listeners.before.event_exited["dapui_config"] = function()
                dapui.close()
            end
            return {
                enabled = true, -- enable this plugin (the default)
                enabled_commands = true, -- create commands DapVirtualTextEnable, DapVirtualTextDisable, DapVirtualTextToggle, (DapVirtualTextForceRefresh for refreshing when debug adapter did not notify its termination)
                highlight_changed_variables = true, -- highlight changed values with NvimDapVirtualTextChanged, else always NvimDapVirtualText
                highlight_new_as_changed = false, -- highlight new variables in the same way as changed variables (if highlight_changed_variables)
                show_stop_reason = true, -- show stop reason when stopped for exceptions
                commented = false, -- prefix virtual text with comment string
                only_first_definition = true, -- only show virtual text at first definition (if there are multiple)
                all_references = false, -- show virtual text on all all references of the variable (not only definitions)
                filter_references_pattern = "<module", -- filter references (not definitions) pattern when all_references is activated (Lua gmatch pattern, default filters out Python modules)
                -- Experimental Features:
                virt_text_pos = "eol", -- position of virtual text, see `:h nvim_buf_set_extmark()`
                all_frames = false, -- show virtual text for all stack frames not only current. Only works for debugpy on my machine.
                virt_lines = false, -- show virtual lines instead of virtual text (will flicker!)
                virt_text_win_col = nil, -- position the virtual text at a fixed window column (starting from the first text column) ,
            }
        end,
    },
    {
        "theHamsta/nvim-dap-virtual-text",
        opts = {},
    },
}
