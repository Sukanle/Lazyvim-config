return {
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
            render = "compact",
            background_colour = background,
        }
    end,
}
