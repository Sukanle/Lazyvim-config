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
      server = {
        clangd = function(_, opts)
          opts.mason = false
          opts.cmd = { "clangd", "--header-insertion=never", "--background-index", "--clang-tidy"}
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
