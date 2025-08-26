return {
  {
    "tweekmonster/startuptime.vim",
    cmd = "StartupTime",
    config = function()
      vim.g.startuptime_tries = 10  -- 多次测试取平均值
    end
  },
  {
    "dstein64/vim-startuptime",
    cmd = "StartupTime"
  }
}
