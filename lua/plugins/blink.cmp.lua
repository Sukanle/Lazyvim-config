return {
    "saghen/blink.cmp",
    version = "v1.*",
    dependencies = {
        { "xzbdmw/colorful-menu.nvim" },
        { "archie-judd/blink-cmp-words" },
        { "Kaiser-Yang/blink-cmp-avante" },
    },
    opts = {
        completion = {
            documentation = {
                auto_show = true,
            },
            menu = {
                auto_show = true,
                auto_show_delay_ms = 0,
                direction_priority = function()
                    local ctx = require("blink.cmp").get_context()
                    local item = require("blink.cmp").get_selected_item()
                    if ctx == nil or item == nil then
                        return { "s", "n" }
                    end

                    local item_text = item.textEdit ~= nil and item.textEdit.newText or item.insertText or item.label
                    local is_multi_line = item_text:find("\n") ~= nil

                    if is_multi_line or vim.g.blink_cmp_upwards_ctx_id == ctx.id then
                        vim.g.blink_cmp_upwards_ctx_id = ctx.id
                        return { "n", "s" }
                    end
                    return { "s", "n" }
                end,
                draw = {
                    columns = { { "kind_icon" }, { "label", gap = 1 } },
                    components = {
                        label = {
                            text = function(ctx)
                                return require("colorful-menu").blink_components_text(ctx)
                            end,
                            highlight = function(ctx)
                                return require("colorful-menu").blink_components_highlight(ctx)
                            end,
                        },
                    },
                },
            },
        },
        signature = {
            enabled = true,
        },
        cmdline = {
            completion = {
                menu = {
                    auto_show = true,
                },
            },
        },
        sources = {
            default = { "avante", "lsp", "path", "snippets", "buffer" },
            providers = {
                snippets = {
                    score_offset = 1000,
                    should_show_items = function(ctx)
                        return ctx.trigger.initial_kind ~= "trigger_character"
                    end,
                },
                thesaurus = {
                    name = "blink-cmp-words",
                    module = "blink-cmp-words.thesaurus",
                    opts = {
                        score_offset = 0,
                        definition_pointers = { "!", "&", "^" },
                        similarity_pointers = { "&", "^" },
                        similarity_depth = 2,
                    },
                },
                dictionary = {
                    name = "blink-cmp-words",
                    module = "blink-cmp-words.dictionary",
                    opts = {
                        dictionary_search_threshold = 3,
                        score_offset = 0,
                        definition_pointers = { "!", "&", "^" },
                    },
                },
                avante = {
                    module = "blink-cmp-avante",
                    name = "Avante",
                },
            },
            per_filetype = {
                text = { "dictionary" },
                markdown = { "lsp", "thesaurus" },
                typst = { "lsp", "snippets", "dictionary" },
                tex = { "dictionary", "thesaurus" },
            },
        },
    },
}
