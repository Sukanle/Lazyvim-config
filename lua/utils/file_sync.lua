return {
    sync_symlink_if_newr = function(src, det)
        local source = vim.uv.fs_stat(src)
        local target = vim.uv.fs_stat(det)

        if not source or not source.mtime.sec then
            vim.notify("Source file does not exist: " .. src, vim.log.levels.ERROR)
            return false
        end

        if vim.uv.fs_readlink(det) == src then
            return true
        elseif not target or not target.mtime.sec then
            vim.notify("Create symlink...", vim.log.levels.INFO)
        elseif source.mtime.sec > target.mtime.sec then
            vim.notify(string.format("Detected %s newer than %s, rebuilding symlink...", src, det), vim.log.levels.INFO)
            vim.uv.fs_unlink(det)
        else
            return false
        end
        local e = vim.uv.fs_symlink(src, det)
        if not e then
            vim.notify("Failed to create symlink: " .. det, vim.log.levels.WARN)
        end
        return true
    end,
}
