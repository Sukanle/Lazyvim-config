-- Shared clangd/clang-format paths and config symlink setup.
local M = {}

local file_sync = require("utils.file_sync")

M.share_dir = vim.fs.joinpath(vim.g.home, "share", "clang-extern-tools")

if vim.g.os.sysname == "Windows_NT" then
    M.home_dir = vim.fs.joinpath(vim.env.LOCALAPPDATA, "clangd")
elseif vim.g.os.sysname == "Darwin" then
    M.home_dir = vim.fs.joinpath(vim.env.HOME, "Library", "Preferences", "clangd")
else
    local config_home = vim.env.XDG_CONFIG_HOME
    if not config_home or config_home == "" then
        config_home = vim.fs.joinpath(vim.env.HOME, ".config")
    end
    M.home_dir = vim.fs.joinpath(config_home, "clangd")
end

---Sync the shared clangd config files into the user config directory.
---Safe to call from multiple plugin specs.
function M.setup()
    if M._done then
        return
    end
    M._done = true

    vim.fn.mkdir(M.home_dir, "p")
    file_sync.sync_symlink_if_newr(
        vim.fs.joinpath(M.share_dir, "config.yaml"),
        vim.fs.joinpath(M.home_dir, "config.yaml")
    )
    file_sync.sync_symlink_if_newr(
        vim.fs.joinpath(M.share_dir, ".clang-format"),
        vim.fs.joinpath(M.home_dir, ".clang-format")
    )
end

return M
