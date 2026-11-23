-- Snacks has no i18n API: patch picker title templates and dashboard rendering.

local M = {}

function M.setup(i18n, hooks)
    hooks.watch("snacks.picker.util", function(util)
        hooks.wrap(util, "tpl", function(original)
            return function(template, data, opts)
                -- Picker title templates pass source/title/preview/live.
                if
                    type(data) == "table"
                    and type(data.title) == "string"
                    and data.source
                    and data.preview ~= nil
                    and data.live ~= nil
                then
                    data = vim.tbl_extend("force", {}, data)
                    data.title = i18n.tr(data.title)
                    data.source = i18n.tr(data.source)
                    template = i18n.tr(template)
                end
                return original(template, data, opts)
            end
        end)
    end)

    hooks.watch("snacks.dashboard", function(dashboard)
        hooks.wrap(dashboard.Dashboard, "format", function(original)
            return function(self, item)
                local copy = vim.tbl_extend("force", {}, item)
                for _, field in ipairs({ "desc", "title", "footer" }) do
                    if type(copy[field]) == "string" then
                        copy[field] = i18n.tr(copy[field])
                    end
                end
                if type(copy.text) == "table" then
                    copy.text = vim.deepcopy(copy.text)
                    if type(copy.text[1]) == "string" then
                        copy.text[1] = i18n.tr(copy.text[1])
                    else
                        for _, chunk in ipairs(copy.text) do
                            if type(chunk[1]) == "string" then
                                chunk[1] = i18n.tr(chunk[1])
                            end
                        end
                    end
                end
                return original(self, copy)
            end
        end)
    end)
end

return M
