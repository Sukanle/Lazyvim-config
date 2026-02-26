-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Tabstop
local opt = vim.opt
opt.expandtab = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.wrap = true
opt.fileencodings = {
    "utf-8",
    "ucs-bom",
    "cp936",
    "gb18030",
    "gb2132",
    "big5",
    "latin1",
}

vim.g.autoformat = false
vim.diagnostic.config({
    virtual_text = false,
    update_in_insert = false,
})

vim.lsp.set_log_level("off")
