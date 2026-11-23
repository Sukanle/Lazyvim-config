-- Auto-load every patch module under `lua/i18n/patches/`.
-- A patch module can return either:
--   * `function(i18n)` — applied immediately, or
--   * `{ apply = function(i18n) ... end }` — applied immediately.

local M = {}

function M.setup(i18n)
    local dir = vim.fs.dirname(debug.getinfo(1, "S").source:sub(2))
    local files = vim.fn.globpath(dir, "*.lua", false, true)
    table.sort(files)

    for _, path in ipairs(files) do
        local name = vim.fs.basename(path)
        if name ~= "init.lua" then
            local module = "i18n.patches." .. name:gsub("%.lua$", "")
            local ok, patch = pcall(require, module)
            if not ok then
                vim.notify(("[i18n] failed to load patch %s: %s"):format(module, patch), vim.log.levels.WARN)
            elseif type(patch) == "function" then
                local applied, err = pcall(patch, i18n)
                if not applied then
                    vim.notify(("[i18n] patch %s failed: %s"):format(module, err), vim.log.levels.WARN)
                end
            elseif type(patch) == "table" and type(patch.apply) == "function" then
                local applied, err = pcall(patch.apply, i18n)
                if not applied then
                    vim.notify(("[i18n] patch %s failed: %s"):format(module, err), vim.log.levels.WARN)
                end
            end
        end
    end
end

return M
