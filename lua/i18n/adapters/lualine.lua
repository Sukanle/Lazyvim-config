-- Lualine mode names are hard-coded in `lualine.utils.mode.get_mode`.
-- Wrap it so NORMAL / INSERT / COMMAND etc. appear in the UI dictionary.

local M = {}

function M.setup(i18n, hooks)
    hooks.watch("lualine.utils.mode", function(mode)
        hooks.wrap(mode, "get_mode", function(original)
            return function(...)
                return i18n.tr(original(...))
            end
        end)
    end)
end

return M
