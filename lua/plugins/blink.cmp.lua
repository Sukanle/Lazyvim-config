return {
    "blink.cmp",
    keymap = { preset = "default" },
    completion = {
        menu = {
            -- Disable automatically showing the menu while typing, instead press `<C-space>` (by default) to show it manually
            auto_show = false,
            -- or per filetype
            -- auto_show = function(ctx, items)
            --     return vim.bo.filetype == "markdown"
            -- end,

            -- Delay before showing the completion menu while typing
            auto_show_delay_ms = 500,
            -- or per filetype
            -- auto_show_delay_ms = function(ctx, items)
            --     return vim.bo.filetype == "markdown" and 1000 or 0
            -- end,
            direction_priority = function()
                local ctx = require("blink.cmp").get_context()
                local item = require("blink.cmp").get_selected_item()
                if ctx == nil or item == nil then
                    return { "s", "n" }
                end

                local item_text = item.textEdit ~= nil and item.textEdit.newText or item.insertText or item.label
                local is_multi_line = item_text:find("\n") ~= nil

                -- after showing the menu upwards, we want to maintain that direction
                -- until we re-open the menu, so store the context id in a global variable
                if is_multi_line or vim.g.blink_cmp_upwards_ctx_id == ctx.id then
                    vim.g.blink_cmp_upwards_ctx_id = ctx.id
                    return { "n", "s" }
                end
                return { "s", "n" }
            end,
        },
        documentation = { auto_show = false },
    },
}
