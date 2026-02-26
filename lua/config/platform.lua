if vim.fn.exists("g:os") == 0 then
    vim.g.os = vim.uv.os_uname()
    if vim.g.os.sysname == "Windows_NT" then
        if vim.fn.executable("pwsh") == 1 then
            vim.opt.shell = "pwsh"
            vim.opt.shellcmdflag =
                "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;"
            vim.opt.shellredir = "-RedirectStandardOutput %s -NoNewWindow -Wait"
            vim.opt.shellpipe = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode"
        elseif vim.fn.executable("powershell") == 1 then
            vim.opt.shell = "powershell"
            vim.opt.shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command"
            vim.opt.shellredir = "| Out-File -Encoding UTF8 %s"
            vim.opt.shellpipe = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode"
        else
            vim.opt.shell = "cmd.exe"
        end
    else
        vim.opt.shell = vim.fn.executable("zsh") == 1 and "zsh" or "bash"
    end
end

if not vim.env.XDG_CONFIG_HOME or vim.env.XDG_CONFIG_HOME == "" then
    if vim.g.os.sysname == "Windows_NT" then
        vim.g.home = vim.env.LOCALAPPDATA .. "\\nvim"
    else
        vim.g.home = vim.env.HOME .. "/.config/nvim"
    end
end
