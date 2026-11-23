-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Feature switches shared by plugin specs.
-- Set `opts.ai.avante = false` to disable Avante.
opts = opts or {}
opts.ai = vim.tbl_deep_extend("force", { avante = true }, opts.ai or {})

-- Tabstop
local opt = vim.opt
opt.expandtab = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.wrap = true
opt.winborder = "rounded"
-- Use box-drawing characters for split borders, matching floating windows.
opt.fillchars:append({
    horiz = "─",
    horizup = "┴",
    horizdown = "┬",
    vert = "│",
    vertleft = "┤",
    vertright = "├",
    verthoriz = "┼",
})
opt.fileencodings = {
    "utf-8",
    "ucs-bom",
    "cp936",
    "gb18030",
    "gb2312",
    "big5",
    "latin1",
}

vim.g.autoformat = false
vim.diagnostic.config({
    virtual_text = false,
    update_in_insert = false,
})

-- vim.lsp.log.set_level("off")
