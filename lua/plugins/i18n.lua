return {
    {
        "folke/which-key.nvim",
        opts = function(_, opts)
            return require("i18n.patches.which-key").translate_opts(opts)
        end,
    },
    {
        "folke/snacks.nvim",
        opts = function(_, opts)
            return require("i18n.patches.snacks").translate_opts(opts)
        end,
    },
}
