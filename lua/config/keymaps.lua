-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Open the Neovim config directory, pre-filtered to init.lua so <CR> opens it by default.
-- Clear the prompt (e.g. <C-u>) to browse all config files.
vim.keymap.set("n", "<leader>fc", function()
    local config = vim.fn.stdpath("config")
    if Snacks and Snacks.picker then
        Snacks.picker.files({
            cwd = config,
            search = "init.lua",
            title = "Neovim Config",
        })
    else
        vim.cmd.edit(vim.fs.joinpath(config, "init.lua"))
    end
end, { desc = "Neovim Config (init.lua)" })
