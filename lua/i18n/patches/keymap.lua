-- Invasive keymap patch.
--
-- LazyVim and most plugins pass `desc` through `vim.api.nvim_set_keymap` (or
-- `vim.keymap.set`, which delegates to it). Wrapping the API lets us translate
-- descriptions before which-key reads them, without touching each plugin.

local M = {}

function M.apply(i18n)
    if _G.__nvim_i18n_keymap_patched then
        return
    end
    _G.__nvim_i18n_keymap_patched = true

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

    local set_keymap = vim.api.nvim_set_keymap
    vim.api.nvim_set_keymap = function(mode, lhs, rhs, opts, ...)
        return set_keymap(mode, lhs, rhs, translate_opts(i18n, opts), ...)
    end

    local buf_set_keymap = vim.api.nvim_buf_set_keymap
    vim.api.nvim_buf_set_keymap = function(buf, mode, lhs, rhs, opts, ...)
        return buf_set_keymap(buf, mode, lhs, rhs, translate_opts(i18n, opts), ...)
    end
end

return M
