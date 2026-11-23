-- which-key has no i18n API: patch its render helpers after the modules load.
-- `view.replace` receives every description (including group labels), and
-- `text.append` handles help/footer strings.

local M = {}

function M.setup(i18n, hooks)
    hooks.watch("which-key.view", function(view)
        hooks.wrap(view, "replace", function(original)
            return function(field, value)
                local text = original(field, value)
                return field == "desc" and i18n.tr(text) or text
            end
        end)
    end)

    hooks.watch("which-key.text", function(text)
        hooks.wrap(text, "append", function(original)
            return function(self, value, opts)
                if opts == "WhichKeySeparator" and type(value) == "string" then
                    value = i18n.tr(value)
                end
                return original(self, value, opts)
            end
        end)
    end)
end

return M
