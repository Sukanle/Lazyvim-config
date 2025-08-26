-- bootstrap lazy.nvim, LazyVim and your plugins
vim.g.load_netrwPlugin = true
vim.g.loaded_matchit = 1
vim.g.loaded_matchparen = 1
vim.g.lazy_download_async = true
vim.g.lazy_install_async = true

require("config.platform")
if vim.g.neovide then
  require("config.neovide")
end
require("config.lazy")
