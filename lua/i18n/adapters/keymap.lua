-- Translate `desc` for every mapping registered after startup.
-- This feeds which-key, Snacks keymap pickers and anything else reading `desc`.

local M = {}

local function translate_opts(i18n, opts)
    if type(opts) == "table" and type(opts.desc) == "string" then
        local translated = i18n.tr(opts.desc)
        if translated ~= opts.desc then
            opts = vim.tbl_extend("force", {}, opts)
            opts.desc = translated
        end
    end
    return opts
end

function M.setup(i18n, hooks)
    hooks.wrap(vim.api, "nvim_set_keymap", function(original)
        return function(mode, lhs, rhs, opts, ...)
            return original(mode, lhs, rhs, translate_opts(i18n, opts), ...)
        end
    end)

    hooks.wrap(vim.api, "nvim_buf_set_keymap", function(original)
        return function(buf, mode, lhs, rhs, opts, ...)
            return original(buf, mode, lhs, rhs, translate_opts(i18n, opts), ...)
        end
    end)
end

return M
