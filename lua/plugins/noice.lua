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
