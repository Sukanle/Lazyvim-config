-- ~/.config/nvim/lua/plugins/transparent.lua
return {
  "xiyaowong/transparent.nvim",
  lazy = false,           -- 禁用 lazy 加载
  priority = 1000,        -- 提高加载优先级，确保在其他插件前加载
  config = function()
    require("transparent").setup({
      extra_groups = {
      },
      exclude_groups = {
      },
    })

    -- 启用透明
    vim.cmd("TransparentEnable")
  end,
}
