return {
  {
    "neovim/nvim-lspconfig",
    optional = true,
    lazy = false,
    opts = {
      inlay_hints = {
        enable = false,
        exclude = { "c", "cpp" },
      },
      autoformat = false,
      setup = {
        clangd = function(_, opts)
          opts.cmd = { "clangd", "--header-insertion=never" }
        end,
        -- -- 可选：关闭 clangd 的代码片段功能（避免自动展开）
        -- capabilities = {
        --   textDocument = {
        --     completion = {
        --       completionItem = {
        --         snippetSupport = false,
        --       },
        --     },
        --   },
        -- },
      },
    },
  },
}
