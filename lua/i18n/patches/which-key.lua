-- which-key has no i18n hook: translate its spec tables directly.
-- Group labels come from `opts.spec`; later `wk.add()` calls are wrapped too.

local M = {}

local function translate_node(node, i18n)
    if type(node) ~= "table" then
        return
    end
    if type(node.group) == "string" then
        node.group = i18n.tr(node.group)
    end
    if type(node.desc) == "string" then
        node.desc = i18n.tr(node.desc)
    end
    for key, value in pairs(node) do
        if key ~= "group" and key ~= "desc" and type(value) == "table" then
            translate_node(value, i18n)
        end
    end
end

---Translate a which-key `opts` table in place.
---@param opts table
function M.translate_opts(opts)
    local i18n = require("i18n")
    for _, spec in ipairs(opts.spec or {}) do
        translate_node(spec, i18n)
    end
    return opts
end

function M.apply(i18n)
    vim.api.nvim_create_autocmd("User", {
        pattern = "VeryLazy",
        callback = function()
            local ok, wk = pcall(require, "which-key")
            if not ok or wk.__i18n_patched then
                return
            end
            wk.__i18n_patched = true
            local add = wk.add
            wk.add = function(spec, opts)
                translate_node(spec, i18n)
                return add(spec, opts)
            end
        end,
    })
end

return M
