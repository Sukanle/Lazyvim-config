local clangd_cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--compile-commands-dir=build",
}

local clangd = require("utils.clangd")
clangd.setup()

return {
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        opts = {
            inlay_hints = { enabled = false },
            servers = {
                clangd = {
                    mason = false,
                    cmd = clangd_cmd,
                },
                rust_analyzer = {
                    mason = false,
                    settings = {
                        ["rust-analyzer"] = {
                            checkOnSave = { command = "clippy" },
                            cargo = { allFeatures = true },
                            procMacro = { enable = true },
                        },
                    },
                },
                zig_analyzer = {
                    mason = false,
                    cmd = { "zig-analyzer" },
                    filetypes = { "zig", "zon" },
                    -- Match directory entries by their exact names instead of using
                    -- root_markers, which on case-insensitive file systems can also
                    -- match the standard library's `std/Build.zig`.
                    root_dir = function(bufnr, on_dir)
                        on_dir(vim.fs.root(bufnr, function(name)
                            return name == "build.zig" or name == ".git"
                        end))
                    end,
                    settings = {
                        ["zig-analyzer"] = vim.empty_dict(),
                    },
                },
                lua_ls = { enabled = false },
                emmylua_ls = {
                    mason = false,
                    settings = {
                        emmylua = {
                            -- Diagnostics come from `emmylua_check` via nvim-lint
                            -- to avoid duplicated entries.
                            diagnostics = { enable = false },
                        },
                    },
                },
                ty = {
                    mason = false,
                    handlers = {
                        -- ty dynamically registers pull diagnostics; drop that
                        -- registration so `ty check` via nvim-lint is the only
                        -- diagnostics source.
                        ["client/registerCapability"] = function(_, params, ctx)
                            params.registrations = vim.tbl_filter(function(reg)
                                return reg.method ~= "textDocument/diagnostic"
                            end, params.registrations or {})
                            return vim.lsp.handlers["client/registerCapability"](nil, params, ctx)
                        end,
                        ["textDocument/publishDiagnostics"] = function() end,
                    },
                },
            },
        },
    },
}
