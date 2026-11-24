-- lua/plugins/coding/conform.lua
return {
    {
        "stevearc/conform.nvim",
        -- optional = true,
        opts = {
            formatters_by_ft = {
                -- Prefer clice's LSP formatting; fall back to clang-format
                -- when no C/C++ LSP with formatting support is attached.
                ["c"] = { "clang-format", lsp_format = "prefer" },
                ["cpp"] = { "clang-format", lsp_format = "prefer" },
                ["rust"] = { "rustfmt" },
                ["zig"] = { "zig" },
                ["markdown"] = { "prettier" },
                ["cmake"] = { "cmakefmt" },
                ["python"] = { "ruff_organize_imports", "ruff_format" },
                ["json"] = { "prettier" },
                ["lua"] = { "luafmt" },
            },
            formatters = {
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
