if vim.fn.exists("g:os") == 0 then
  if vim.fn.has("win64") == 1 or vim.fn.has("win32") == 1 or vim.fn.has("win16") == 1 then
    vim.g.os = "Windows"
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
  elseif vim.fn.has("mac") == 1 then
    vim.g.os = "MacOS"
  elseif vim.fn.has("linux") then
    vim.g.os = "Linux"
  else
    vim.g.os = "Unix"
      vim.opt.shell = vim.fn.executable("zsh") == 1 and "zsh" or "bash"
  end
end
