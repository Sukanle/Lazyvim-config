local titles = {
    cmdline = "Cmdline",
    search_down = "Search Down",
    search_up = "Search Up",
    filter = "Filter",
    lua = "Lua",
    help = "Help",
    calculator = "Calculator",
    input = "Input",
}

return {
    {
        "rcarriga/nvim-notify",
        lazy = true,
        opts = function()
            local function background()
                local bg = vim.api.nvim_get_hl(0, { name = "Normal" }).bg
                return type(bg) == "number" and string.format("#%06x", bg) or "#1a1b26"
            end

            return {
                stages = "fade_in_slide_out",
                timeout = 3000,
                max_width = 60,
                render = "default",
                background_colour = background,
            }
        end,
    },
    {
        "folke/noice.nvim",
        opts = function(_, opts)
            opts.cmdline = opts.cmdline or {}
            opts.cmdline.format = opts.cmdline.format or {}

            -- Use nvim-notify instead of Snacks for notification animations.
            opts.views = opts.views or {}
            opts.views.notify = vim.tbl_deep_extend("force", opts.views.notify or {}, {
                backend = "notify",
                fallback = "mini",
            })

            -- LSP hover (`K`) inherits Noice's popup view but defaults to no
            -- border. This preset adds the rounded border to hover docs and
            -- signature help.
            opts.presets = opts.presets or {}
            opts.presets.lsp_doc_border = true

            local i18n = require("i18n")
            for name, label in pairs(titles) do
                local format = opts.cmdline.format[name]
                if format ~= false then
                    format = type(format) == "table" and format or {}
                    format.title = " " .. i18n.tr(label) .. " "
                    opts.cmdline.format[name] = format
                end
            end
        end,
    },
}
