local clangd_cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--compile-commands-dir=build",
}

local share_path = vim.g.home .. "/share/clang-extern-tools/"
local home_dir
if vim.g.os.sysname == "Windows_NT" then
    home_dir = vim.env.LOCALAPPDATA .. "\\clangd\\"
elseif vim.g.os.sysname == "Darwin" then
    home_dir = vim.env.HOME .. "/Library/Preferences/clangd/"
else
    if not vim.env.XDG_CONFIG_HOME or vim.env.XDG_CONFIG_HOME == "" then
        home_dir = vim.env.HOME .. "/.config/clangd/"
    else
        home_dir = vim.env.XDG_CONFIG_HOME .. "/clangd/"
    end
end

local file_sync = require("utils.file_sync")
file_sync.sync_symlink_if_newr(share_path .. "config.yaml", home_dir .. "config.yaml")

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
                lua_ls = {
                    mason = true,
                    settings = {
                        Lua = {
                            workspace = {
                                library = {
                                    vim.fn.expand(
                                        vim.g.home .. "/share/lua-language-server/LLS-Addons/addons/xmake/module/library"
                                    ),
                                },
                                checkThirdParty = false,
                            },
                            diagnostics = {
                                globals = { "xmake", "target", "set_kind", "add_files" },
                            },
                        },
                    },
                },
            },
        },
    },
}
