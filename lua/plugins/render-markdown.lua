local function preview_module()
    return require("render-markdown.core.preview")
end

local function manager_module()
    local ok, manager = pcall(require, "render-markdown.core.manager")
    return ok and manager or nil
end

local function source_enabled(src)
    return vim.bo[src].filetype ~= "markdown"
end

local function cleanup(preview)
    local manager = manager_module()
    for src, dst in pairs(preview.buffers or {}) do
        if not vim.api.nvim_buf_is_valid(dst) then
            preview.buffers[src] = nil
            if manager then
                pcall(manager.set_buf, src, source_enabled(src))
            end
        end
    end
end

local function close_source(preview, src)
    local dst = preview.buffers[src]
    if not dst then
        return
    end
    if vim.api.nvim_buf_is_valid(dst) then
        pcall(vim.api.nvim_buf_delete, dst, { force = true })
    end
    preview.buffers[src] = nil
    local manager = manager_module()
    if manager then
        pcall(manager.set_buf, src, source_enabled(src))
    end
end

local function is_preview_buffer(buf, preview)
    for _, dst in pairs(preview.buffers or {}) do
        if dst == buf then
            return true
        end
    end
    return false
end

local function preview_source(preview)
    for src in pairs(preview.buffers or {}) do
        return src
    end
end

local function current_markdown()
    local buf = vim.api.nvim_get_current_buf()
    if vim.bo[buf].filetype ~= "markdown" then
        return
    end
    local manager = manager_module()
    if not manager or not manager.attached(buf) then
        return
    end
    return buf
end

local function keep_raw()
    local buf = current_markdown()
    if not buf then
        return
    end
    local ok, preview = pcall(preview_module)
    if ok and is_preview_buffer(buf, preview) then
        return
    end
    local manager = manager_module()
    if manager then
        pcall(manager.set_buf, buf, false)
    end
end

local function open_for(buf)
    local ok, preview = pcall(preview_module)
    if not ok then
        return
    end
    cleanup(preview)
    if preview.buffers[buf] then
        return
    end
    local old = preview_source(preview)
    if old then
        close_source(preview, old)
    end
    preview.open(buf)
end

local function toggle()
    local buf = current_markdown()
    if not buf then
        return
    end
    local ok, preview = pcall(preview_module)
    if not ok then
        return
    end
    cleanup(preview)
    if preview.buffers[buf] then
        close_source(preview, buf)
    else
        open_for(buf)
    end
end

local function follow()
    local buf = current_markdown()
    if not buf then
        return
    end
    local ok, preview = pcall(preview_module)
    if not ok then
        return
    end
    cleanup(preview)
    if is_preview_buffer(buf, preview) or not preview_source(preview) then
        return
    end
    if not preview.buffers[buf] then
        open_for(buf)
    end
end

return {
    {
        "MeanderingProgrammer/render-markdown.nvim",
        ft = { "markdown", "Avante" },
        opts = {
            overrides = {
                filetype = {
                    markdown = {
                        enabled = false,
                    },
                },
                preview = {
                    enabled = true,
                    render_modes = true,
                },
            },
        },
        init = function()
            vim.keymap.set("n", "<leader>md", toggle, { desc = "Markdown Preview (render-markdown)" })
            vim.api.nvim_create_autocmd("BufEnter", {
                callback = follow,
                desc = "Follow active Markdown buffer in render-markdown preview",
            })
            vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
                callback = keep_raw,
                desc = "Keep Markdown source buffers unrendered",
            })
        end,
    },
}
