local clangd_cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--log=verbose",
}

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
