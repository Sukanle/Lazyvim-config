-- lua/plugins/linting.lua
-- Use EmmyLua's checker for Lua and ty's checker for Python.

-- Analyze from the project root so `require` paths resolve and the project's
-- `.emmyrc.json` is discovered. The parser keeps only diagnostics for the
-- current buffer.
local function check_root()
    local bufnr = vim.api.nvim_get_current_buf()
    local name = vim.api.nvim_buf_get_name(bufnr)
    if name == "" then
        return nil
    end
    local root = vim.fs.root(bufnr, { ".emmyrc.json", ".emmyrc.lua", ".luarc.json", ".luarc.jsonc", ".git" })
    return root or vim.fs.dirname(name)
end

---@param output string
---@param bufnr integer
---@return vim.Diagnostic[]
local function parse_emmylua(output, bufnr)
    local ok, decoded = pcall(vim.json.decode, output)
    if not ok or type(decoded) ~= "table" then
        return {}
    end

    local target = vim.fs.normalize(vim.api.nvim_buf_get_name(bufnr))
    local diagnostics = {}
    local seen = {}

    for _, entry in ipairs(decoded) do
        local file = entry.file and vim.fs.normalize(entry.file)
        if not file or target == "" or file == target then
            for _, d in ipairs(entry.diagnostics or {}) do
                local range = d.range or {}
                local start = range.start or {}
                local finish = range["end"] or start
                local diagnostic = {
                    lnum = start.line or 0,
                    col = start.character or 0,
                    end_lnum = finish.line or start.line or 0,
                    end_col = finish.character or start.character or 0,
                    message = d.message or "",
                    severity = d.severity or vim.diagnostic.severity.WARN,
                    source = d.source or "EmmyLua",
                    code = d.code,
                    tags = d.tags,
                }
                local key = table.concat({
                    diagnostic.lnum,
                    diagnostic.col,
                    diagnostic.end_lnum,
                    diagnostic.end_col,
                    diagnostic.code or "",
                    diagnostic.message,
                }, ":")
                if not seen[key] then
                    seen[key] = true
                    diagnostics[#diagnostics + 1] = diagnostic
                end
            end
        end
    end

    return diagnostics
end

---@param path string
---@param cwd string
---@return string
local function absolute_path(path, cwd)
    if path:sub(1, 1) == "/" or path:match("^%a:[/\\]") then
        return vim.fs.normalize(path)
    end
    return vim.fs.normalize(vim.fs.joinpath(cwd, path))
end

local ty_severities = {
    blocker = vim.diagnostic.severity.ERROR,
    critical = vim.diagnostic.severity.ERROR,
    major = vim.diagnostic.severity.ERROR,
    minor = vim.diagnostic.severity.WARN,
    info = vim.diagnostic.severity.INFO,
}

-- Resolve the Python project from the buffer so ty finds the right
-- `pyproject.toml` / virtualenv regardless of Neovim's working directory.
local function ty_project()
    local bufnr = vim.api.nvim_get_current_buf()
    local name = vim.api.nvim_buf_get_name(bufnr)
    if name == "" then
        return vim.fn.getcwd()
    end
    local root = vim.fs.root(bufnr, {
        "ty.toml",
        "pyproject.toml",
        "setup.py",
        "setup.cfg",
        "requirements.txt",
        ".git",
    })
    return root or vim.fs.dirname(name)
end

---@param output string
---@param bufnr integer
---@param cwd string
---@return vim.Diagnostic[]
local function parse_ty(output, bufnr, cwd)
    local ok, decoded = pcall(vim.json.decode, output)
    if not ok or type(decoded) ~= "table" then
        return {}
    end

    local target = vim.fs.normalize(vim.api.nvim_buf_get_name(bufnr))
    local diagnostics = {}

    for _, item in ipairs(decoded) do
        local location = item.location or {}
        local positions = location.positions or {}
        local first = positions.begin or {}
        local last = positions["end"] or first
        local file = location.path and absolute_path(location.path, cwd) or nil

        if not file or target == "" or file == target then
            local message = item.description or ""
            local code = item.check_name
            if code and message:sub(1, #code + 2) == code .. ": " then
                message = message:sub(#code + 3)
            end
            diagnostics[#diagnostics + 1] = {
                lnum = (first.line or 1) - 1,
                col = (first.column or 1) - 1,
                end_lnum = (last.line or first.line or 1) - 1,
                end_col = (last.column or first.column or 1) - 1,
                message = message,
                severity = ty_severities[item.severity] or vim.diagnostic.severity.ERROR,
                source = "ty",
                code = code,
            }
        end
    end

    return diagnostics
end

return {
    {
        "mfussenegger/nvim-lint",
        opts = {
            linters_by_ft = {
                lua = { "emmylua_check" },
                python = { "ty_check" },
            },
            linters = {
                emmylua_check = {
                    cmd = "emmylua_check",
                    stdin = false,
                    append_fname = false,
                    args = { "-f", "json", check_root },
                    ignore_exitcode = true,
                    condition = function(ctx)
                        return ctx.filename ~= ""
                    end,
                    parser = parse_emmylua,
                },
                ty_check = {
                    cmd = "ty",
                    stdin = false,
                    args = { "check", "--output-format", "gitlab", "--no-progress", "--project", ty_project },
                    ignore_exitcode = true,
                    condition = function(ctx)
                        return ctx.filename ~= ""
                    end,
                    parser = parse_ty,
                },
            },
        },
    },
}
