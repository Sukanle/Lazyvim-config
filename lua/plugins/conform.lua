-- lua/plugins/formatter.lua
local M = {
    {
        "stevearc/conform.nvim",
        optional = true,
        opts = {
            formatters_by_ft = {
                c = { "clang_format" },
                cpp = { "clang_format" },
                ["c++"] = { "clang_format" },
            },
            formatters = {
                clang_format = {
                    command = "clang-format",
                    args = function()
                        local vim = vim

                        -- 构建主目录路径
                        local home_dir
                        if vim.g.os == "Windows" then
                            home_dir = vim.env.LOCALAPPDATA .. "\\clangd"
                        elseif vim.g.os == "MacOS" then
                            home_dir = vim.env.HOME .. "/Library/Preferences/clangd"
                        else
                            home_dir = vim.env.HOME .. "/clangd"
                        end

                        -- 检查当前工作目录是否存在 .clang-format
                        local cwd_config = vim.fn.getcwd() .. "/.clang-format"
                        if vim.fn.filereadable(cwd_config) == 1 then
                            return { "-style=file:" .. cwd_config }
                        end

                        -- 检查用户主目录是否存在 .clang-format
                        local home_config = home_dir .. "/.clang-format"
                        if vim.fn.filereadable(home_config) == 1 then
                            return { "-style=file:" .. home_config }
                        end

                        -- 回退到默认（-style=file 会自动搜索，但为了明确性也可保留）
                        return { "-style=file" }
                    end,
                },
            },
        },
    },
}

return M
