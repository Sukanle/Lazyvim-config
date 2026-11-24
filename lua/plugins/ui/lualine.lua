return {
    "nvim-lualine/lualine.nvim",
    opts = {
        options = {
            theme = "auto",
            section_separators = { left = "", right = "" },
            component_separators = { left = "", right = "" },
        },
        sections = {
            lualine_a = {
                {
                    "mode",
                    fmt = function(mode)
                        return require("i18n").tr(mode)
                    end,
                },
            },
            lualine_c = {},
            lualine_x = {},
        },
    },
}
