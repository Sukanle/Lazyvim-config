return {
    "nvim-lualine/lualine.nvim",
    opts = {
        options = {
            theme = "auto",
            section_separators = { left = "", right = "" },
        },
        sections = {
            lualine_c = {
                -- "%=", -- 中间留空，可按需添加
            },
            lualine_x = {},
        },
    },
}

-- return {
--     {
--         "nvim-lualine/lualine.nvim",
--         opts = function(_, opts)
--             -- 颜色定义
--             local colors = {
--                 blue = "#80a0ff",
--                 cyan = "#79dac8",
--                 black = "#080808",
--                 white = "#c6c6c6",
--                 red = "#ff5189",
--                 violet = "#d183e8",
--                 grey = "#303030",
--             }
--
--             -- Bubbles 主题
--             local bubbles_theme = {
--                 normal = {
--                     a = { bg = C.blue, fg = C.mantle, gui = "bold" },
--                     b = { bg = C.surface0, fg = C.blue },
--                     c = { bg = transparent_bg, fg = C.text },
--                 },
--
--                 insert = {
--                     a = { bg = C.green, fg = C.base, gui = "bold" },
--                     b = { bg = C.surface0, fg = C.green },
--                 },
--
--                 terminal = {
--                     a = { bg = C.green, fg = C.base, gui = "bold" },
--                     b = { bg = C.surface0, fg = C.green },
--                 },
--
--                 command = {
--                     a = { bg = C.peach, fg = C.base, gui = "bold" },
--                     b = { bg = C.surface0, fg = C.peach },
--                 },
--                 visual = {
--                     a = { bg = C.mauve, fg = C.base, gui = "bold" },
--                     b = { bg = C.surface0, fg = C.mauve },
--                 },
--                 replace = {
--                     a = { bg = C.red, fg = C.base, gui = "bold" },
--                     b = { bg = C.surface0, fg = C.red },
--                 },
--                 inactive = {
--                     a = { bg = transparent_bg, fg = C.blue },
--                     b = { bg = transparent_bg, fg = C.surface1, gui = "bold" },
--                     c = { bg = transparent_bg, fg = C.overlay0 },
--                 },
--             }
--
--             return opts
--         end,
--     },
-- }
