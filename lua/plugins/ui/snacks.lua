return {
    {
        "folke/snacks.nvim",
        init = function()
            -- LazyVim's "news" style (used by <leader>L) does not set a border.
            -- It registers the style later, so pre-seed it here; existing style
            -- values win when LazyVim calls config.style("news", ...).
            require("snacks").config.style("news", {
                border = "rounded",
            })
        end,
    },
}
