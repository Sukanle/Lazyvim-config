-- lua/plugins/linting.lua
-- Use EmmyLua's checker as the Lua linter.

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
                    col = (start.character or 0) + 1,
                    end_lnum = finish.line or start.line or 0,
                    end_col = (finish.character or start.character or 0) + 1,
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

return {
    {
        "mfussenegger/nvim-lint",
        opts = {
            linters_by_ft = {
                lua = { "emmylua_check" },
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
            },
        },
    },
}
