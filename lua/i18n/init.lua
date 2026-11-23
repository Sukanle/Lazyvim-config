-- Lightweight Chinese/localization layer for Neovim.
--
-- Design:
--   * `locales/<locale>/` contains distributed dictionaries (English -> translation).
--   * `adapters/` contains independent hooks for plugins without an i18n API.
--   * `hooks.lua` provides the generic watch/wrap interface used by adapters.
--   * Missing entries fall back to the original English text.
--
-- Locale resolution:
--   `opts.locale` > `vim.g.i18n_locale` > "auto"
--   "auto" checks LC_ALL > LC_MESSAGES > LANG.
-- English locales (en, en_US, en_UK, C, POSIX) skip dictionaries and adapters.
-- `zh_CN.UTF-8` is normalized to `zh_CN`; `zh_CN` falls back to `zh`.

local M = {
    locale = "",
    dict = {},
    loaded_files = {},
}

local function notify(message, level)
    vim.notify("[i18n] " .. message, level or vim.log.levels.WARN)
end

local function env_locale()
    for _, name in ipairs({ "LC_ALL", "LC_MESSAGES", "LANG" }) do
        local value = vim.env[name]
        if type(value) == "string" and value ~= "" then
            return value
        end
    end
    return ""
end

local function normalize_locale(locale)
    return (locale or ""):gsub("[%.@].*$", "")
end

local function configured_locale(opts)
    local value = opts.locale
    if type(value) ~= "string" or value == "" or value == "auto" then
        value = vim.g.i18n_locale
    end
    if type(value) ~= "string" or value == "" then
        value = "auto"
    end
    return value
end

local function is_english(locale)
    local name = locale:lower()
    return name == "c" or name == "posix" or name == "en" or name:match("^en[_%-]") ~= nil
end

local function add_entries(prefix, part)
    if type(part) ~= "table" then
        notify(("locale file %s must return a table"):format(prefix))
        return
    end
    for source, translation in pairs(part) do
        if type(source) == "string" and type(translation) == "string" then
            M.dict[source] = translation
        end
    end
end

local function load_file(path)
    local chunk, err = loadfile(path)
    if not chunk then
        notify(("cannot load %s: %s"):format(path, err))
        return
    end
    local ok, part = pcall(chunk)
    if not ok then
        notify(("error in %s: %s"):format(path, part))
        return
    end
    table.insert(M.loaded_files, path)
    add_entries(path, part)
end

local function locale_root()
    return vim.fs.joinpath(vim.fn.stdpath("config"), "lua", "i18n", "locales")
end

---@param locale string
---@return boolean
local function load_locale(locale)
    if locale == "" or locale == "C" or locale == "POSIX" then
        return false
    end

    local root = locale_root()
    local found = false

    -- Support both `locales/zh_CN.lua` and `locales/zh_CN/*.lua`.
    local single = vim.fs.joinpath(root, locale .. ".lua")
    if vim.fn.filereadable(single) == 1 then
        load_file(single)
        found = true
    end

    local dir = vim.fs.joinpath(root, locale)
    if vim.fn.isdirectory(dir) == 1 then
        local files = vim.fn.globpath(dir, "**/*.lua", false, true)
        table.sort(files)
        for _, path in ipairs(files) do
            -- `init.lua` is reserved for local helpers, not dictionaries.
            if vim.fs.basename(path) ~= "init.lua" then
                load_file(path)
                found = true
            end
        end
    end

    return found
end

---Translate an English source string. Unknown strings are returned unchanged.
---@param text any
---@return any
function M.tr(text)
    if type(text) ~= "string" then
        return text
    end
    return M.dict[text] or text
end

---Recursively translate selected fields in a table. Useful for plugin option tables.
---@param value any
---@param fields table<string, boolean>
---@return any
function M.translate_fields(value, fields)
    if type(value) ~= "table" then
        return value
    end
    for key, item in pairs(value) do
        if fields[key] and type(item) == "string" then
            value[key] = M.tr(item)
        elseif type(item) == "table" then
            M.translate_fields(item, fields)
        end
    end
    return value
end

---Load the current locale and install all adapters.
---@param opts? { locale?: string, adapters?: boolean, patches?: boolean }
function M.setup(opts)
    opts = opts or {}

    if vim.g.i18n_enabled == false then
        return M
    end

    local requested = configured_locale(opts)
    M.locale = normalize_locale(requested == "auto" and env_locale() or requested)
    if M.locale == "" then
        return M
    end

    -- English locales use the original strings; skip dictionary loading and hooks.
    if is_english(M.locale) then
        return M
    end

    if not load_locale(M.locale) and M.locale:find("_") then
        -- zh_CN -> zh fallback for dictionaries shared by regional variants.
        load_locale(M.locale:match("^([^_]+)") or "")
    end

    if opts.patches ~= false and opts.adapters ~= false then
        local hooks = require("i18n.hooks")
        hooks.start()
        require("i18n.adapters").setup(M, hooks)
    end

    return M
end

-- Alias matching the common `i18n.translate(text, domain)` convention.
M.translate = M.tr

return M
