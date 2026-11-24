-- lua/plugins/conform.lua
local clangd = require("utils.clangd")
clangd.setup()

return {
    {
        "stevearc/conform.nvim",
        -- optional = true,
        opts = {
            formatters_by_ft = {
                ["c"] = { "clang_format" },
                ["cpp"] = { "clang_format" },
                ["c++"] = { "clang_format" },
                ["rust"] = { "rustfmt" },
                ["zig"] = { "zig" },
                ["markdown"] = { "prettier" },
                ["cmake"] = { "cmakefmt" },
                ["python"] = { "ruff_organize_imports", "ruff_format" },
                ["json"] = { "prettier" },
                ["lua"] = { "luafmt" },
            },
            formatters = {
                clang_format = {
                    command = "clang-format",
                    args = function()
                        -- 构建主目录路径
                        -- 检查当前工作目录是否存在 .clang-format
                        local cwd_config = vim.fn.getcwd() .. "/.clang-format"
                        if vim.fn.filereadable(cwd_config) == 1 then
                            return { "-style=file:" .. cwd_config }
                        end

                        -- 检查用户主目录是否存在 .clang-format
                        local home_config = vim.fs.joinpath(clangd.home_dir, ".clang-format")
                        if vim.fn.filereadable(home_config) == 1 then
                            return { "-style=file:" .. home_config }
                        end

                        -- 回退到默认（-style=file 会自动搜索，但为了明确性也可保留）
                        return { "-style=file" }
                    end,
                },
                zig = {
                    command = "zig",
                    args = function()
                        return { "fmt" }
                    end,
                },
                cmakefmt = {
                    command = "cmakefmt",
                    args = { "-" },
                    stdin = true,
                },
                luafmt = {
                    command = "luafmt",
                    args = { "--stdin", "--stdin-filename", "$FILENAME", "--level", "lua-jit" },
                    stdin = true,
                },
            },
        },
    },
}
