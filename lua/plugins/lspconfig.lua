local clangd_cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--log=verbose",
}

local share_path = vim.g.home .. "/share/clang-extern-tools/"
local home_dir
if vim.g.os.sysname == "Windows_NT" then
    home_dir = vim.env.LOCALAPPDATA .. "\\clangd\\"
elseif vim.g.os.sysname == "Darwin" then
    home_dir = vim.env.HOME .. "/Library/Preferences/clangd/"
else
    home_dir = vim.env.HOME .. "/clangd/"
end

local file_sync = require("utils.file_sync")
file_sync.sync_symlink_if_newr(share_path .. "config.yaml", home_dir .. "config.yaml")
-- file_sync.sync_symlink_if_newr(share_path .. ".clang-format", home_dir .. ".clang-format")


return {
    {
        "neovim/nvim-lspconfig",
        opts = {
            inlay_hints = { enabled = false },
            servers = {
                clangd = {
                    mason = false,
                    cmd = clangd_cmd,
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
