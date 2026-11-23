-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Switch to the Neovim config directory and open its init.lua directly.
vim.keymap.set("n", "<leader>fc", function()
    local config = vim.fn.stdpath("config")
    vim.fn.chdir(config)
    vim.cmd.edit({ args = { vim.fs.joinpath(config, "init.lua") } })
end, { desc = "Neovim Config (init.lua)" })
