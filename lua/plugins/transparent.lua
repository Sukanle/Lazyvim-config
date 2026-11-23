return {
    "xiyaowong/transparent.nvim",
    lazy = false,
    config = function()
        -- 生成所有 c 区高亮组名称（含所有模式 + inactive）
        local modes = { "normal", "insert", "visual", "replace", "command", "terminal" }
        local c_groups = {}
        for _, mode in ipairs(modes) do
            table.insert(c_groups, "lualine_c_" .. mode)
        end
        table.insert(c_groups, "lualine_inactive_c")  -- 非活动窗口的 c 区

        require("transparent").setup({
            extra_groups = {
                "NormalFloat",
                "FloatBorder",
                "NvimTreeNormal",
                "NvimTreeVertSplit",
                "TelescopeNormal",
                "TelescopeBorder",
                "WhichKeyNormal",
                "WhichKeyBorder",
                "NotifyBackground",
                "Pmenu",
                "TabLine",
                "TabLineFill",
                "TabLineSel",
                -- 追加 c 区高亮组（展开）
                unpack(c_groups),
            },
            exclude_groups = {
                "CursorLine",
                "CursorLineNr",
                "Visual",
                "VisualNOS",
                "Search",
                "IncSearch",
                "CurSearch",
                "Substitute",
                "PmenuSel",
                "PmenuSbar",
                "PmenuThumb",
                "BlinkCmpMenuSelection",
                "BlinkCmpScrollBarThumb",
                "BlinkCmpScrollBarGutter",
                "TelescopeSelection",
                "TelescopeSelectionCaret",
                "NeoTreeCursorLine",
                "SnacksPickerCursor",
                "SnacksPickerSelected",
            },
            on_clear = function()
                vim.api.nvim_set_hl(0, "LineNr", { fg = "#3f84c8" })
                vim.api.nvim_set_hl(0, "FloatBorder", { fg = "#3f84c8", bg = "NONE" })
                vim.api.nvim_set_hl(0, "NormalFloat", { fg = "#c8ccd4", bg = "NONE" })
            end,
        })

        -- 如果你仍想透明其他插件前缀（如 BufferLine 等），保留它们
        require("transparent").clear_prefix("BufferLine")
        require("transparent").clear_prefix("NeoTree")
        require("transparent").clear_prefix("Snacks")
        require("transparent").clear_prefix("BlinkCmp")

        vim.cmd("TransparentEnable")
    end,
}
