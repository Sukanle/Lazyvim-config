-- Auto-register every adapter under `lua/i18n/adapters/`.
--
-- An adapter is an independent file and can return:
--   * `function(i18n, hooks)` — legacy shorthand, or
--   * `{ setup = function(i18n, hooks) ... end }`.
--
-- Add a new plugin hook by creating `lua/i18n/adapters/<name>.lua`; no central
-- registration is needed.

local M = {}

function M.setup(i18n, hooks)
    local dir = vim.fs.dirname(debug.getinfo(1, "S").source:sub(2))
    local files = vim.fn.globpath(dir, "*.lua", false, true)
    table.sort(files)

    for _, path in ipairs(files) do
        local name = vim.fs.basename(path)
        if name ~= "init.lua" then
            local module = "i18n.adapters." .. name:gsub("%.lua$", "")
            local ok, adapter = pcall(require, module)
            if not ok then
                vim.notify(("[i18n] failed to load adapter %s: %s"):format(module, adapter), vim.log.levels.WARN)
            elseif type(adapter) == "function" then
                local applied, err = pcall(adapter, i18n, hooks)
                if not applied then
                    vim.notify(("[i18n] adapter %s failed: %s"):format(module, err), vim.log.levels.WARN)
                end
            elseif type(adapter) == "table" and type(adapter.setup) == "function" then
                local applied, err = pcall(adapter.setup, i18n, hooks)
                if not applied then
                    vim.notify(("[i18n] adapter %s failed: %s"):format(module, err), vim.log.levels.WARN)
                end
            end
        end
    end
end

return M
