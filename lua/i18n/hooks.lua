-- Generic hook interface for localizing modules that have no i18n API.
--
-- Usage:
--   local hooks = require("i18n.hooks")
--   hooks.watch("some.module", function(mod)
--     hooks.wrap(mod, "format", function(original)
--       return function(...)
--         local text = original(...)
--         return i18n.tr(text)
--       end
--     end)
--   end)
--
-- `watch` hooks the module loader instead of `require`-ing early, so plugins can
-- still be lazy-loaded. `wrap` records an undo function for `hooks.stop()`.

local M = {}

local searchers = package.searchers or package.loaders
local targets, undo = {}, {}
local searcher

---Run `callback(module)` when `name` is loaded, or immediately if it already is.
---Multiple callbacks per module are supported.
---@param name string
---@param callback fun(module: table)
function M.watch(name, callback)
    if package.loaded[name] then
        callback(package.loaded[name])
        return
    end
    targets[name] = targets[name] or {}
    table.insert(targets[name], callback)
end

---Wrap `module[key]` with `make(original)`.
---`fallback` is used when the method is inherited from a metatable.
---@param module table
---@param key string
---@param make fun(original: function): function
---@param fallback? function
function M.wrap(module, key, make, fallback)
    local original = module[key] or fallback
    local own = rawget(module, key)
    assert(type(original) == "function", "i18n: unsupported adapter method " .. key)
    local wrapper = make(original)
    module[key] = wrapper
    undo[#undo + 1] = function()
        if module[key] == wrapper then
            module[key] = own
        end
    end
end

function M.start()
    if searcher then
        return
    end

    searcher = function(name)
        local callbacks = targets[name]
        if not callbacks then
            return
        end

        local after = false
        for _, loader in ipairs(searchers) do
            if loader == searcher then
                after = true
            elseif after then
                local loaded, path = loader(name)
                if type(loaded) == "function" then
                    return function(...)
                        local module = loaded(...)
                        targets[name] = nil
                        for _, callback in ipairs(callbacks) do
                            local ok, err = pcall(callback, module or package.loaded[name])
                            if not ok then
                                vim.notify(("[i18n] hook for %s failed: %s"):format(name, err), vim.log.levels.WARN)
                            end
                        end
                        return module
                    end,
                        path
                end
            end
        end
    end

    table.insert(searchers, 1, searcher)
end

function M.stop()
    for i = #undo, 1, -1 do
        undo[i]()
    end
    for i, loader in ipairs(searchers) do
        if loader == searcher then
            table.remove(searchers, i)
            break
        end
    end
    targets, undo = {}, {}
    searcher = nil
end

return M
