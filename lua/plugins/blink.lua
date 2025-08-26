return {
  {
    "blink.cmp",
    lazy = false,
    enabled = function()
      return not vim.tbl_contains({ "lua", "markdown", "c", "cpp", "python" }, vim.bo.filetype)
    end,
    sources = {
      providers = {
        cmdline = {
          -- ignores cmdline completions when executing shell commands
          enabled = function()
            return vim.fn.getcmdtype() ~= ":" or not vim.fn.getcmdline():match("^[%%0-9,'<>%-]*!")
          end,
        },
      },
    },
    keymap = {
    preset = 'default',
    ['<C-1>'] = { function(cmp) cmp.accept({ index = 1 }) end },
    ['<C-2>'] = { function(cmp) cmp.accept({ index = 2 }) end },
    ['<C-3>'] = { function(cmp) cmp.accept({ index = 3 }) end },
    ['<C-4>'] = { function(cmp) cmp.accept({ index = 4 }) end },
    ['<C-5>'] = { function(cmp) cmp.accept({ index = 5 }) end },
    ['<C-6>'] = { function(cmp) cmp.accept({ index = 6 }) end },
    ['<C-7>'] = { function(cmp) cmp.accept({ index = 7 }) end },
    ['<C-8>'] = { function(cmp) cmp.accept({ index = 8 }) end },
    ['<C-9>'] = { function(cmp) cmp.accept({ index = 9 }) end },
    ['<C-0>'] = { function(cmp) cmp.accept({ index = 10 }) end },
  },
    completion = {
      menu = {
        draw = {
          columns = { { 'item_idx' }, { 'kind_icon' }, { 'label', 'label_description', gap = 1 } },
          components = {
            item_idx = {
              text = function(ctx)
                return ctx.idx == 10 and '0' or ctx.idx >= 10 and ' ' or tostring(ctx.idx)
              end,
              highlight = 'BlinkCmpItemIdx' -- optional, only if you want to change its color
            },
          },
        },
      },
    },
  },
}
