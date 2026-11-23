-- Snacks has no translation API. Translate option fields and wrap picker titles.

local M = {}

---Translate Snacks opts (`dashboard` key descriptions, picker titles, etc.).
---@param opts table
function M.translate_opts(opts)
    local i18n = require("i18n")
    i18n.translate_fields(opts, {
        desc = true,
        title = true,
        group = true,
    })
    return opts
end

function M.apply(i18n)
    if M.applied then
        return
    end
    M.applied = true
    vim.api.nvim_create_autocmd("User", {
        pattern = "VeryLazy",
        callback = function()
            local ok, snacks = pcall(require, "snacks")
            if not ok or not snacks.picker then
                return
            end

            -- Translate explicit picker titles passed by other plugins/keymaps.
            local pick = snacks.picker.pick
            local util = require("snacks.picker.util")
            snacks.picker.pick = function(source, opts, ...)
                if type(opts) ~= "table" and type(source) == "table" then
                    source, opts = nil, source
                end
                if type(opts) == "table" and type(opts.title) == "string" then
                    opts = vim.tbl_extend("force", {}, opts)
                    opts.title = i18n.tr(opts.title)
                elseif type(opts) == "table" then
                    local name = opts.source or (type(source) == "string" and source)
                    if name then
                        local title = i18n.tr(util.title(name))
                        if title ~= util.title(name) then
                            opts = vim.tbl_extend("force", {}, opts)
                            opts.title = title
                        end
                    end
                end
                return pick(source, opts, ...)
            end

            -- Translate titles defined on Snacks picker sources.
            local ok_sources, sources = pcall(require, "snacks.picker.config.sources")
            if ok_sources then
                for _, source in pairs(sources) do
                    if type(source) == "table" and type(source.title) == "string" then
                        source.title = i18n.tr(source.title)
                    end
                end
            end
        end,
    })
end

return M
