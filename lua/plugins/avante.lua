return {
    "yetone/avante.nvim",
    build = vim.fn.has("win32") ~= 0 and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
        or "make",
    event = "VeryLazy",
    version = false,
    opts = {
        provider = "opencode",
        acp_providers = {
            opencode = {
                command = "opencode",
                args = { "acp" },
                env = {
                    OPENCODE_API_KEY = vim.env.OPENCODE_API_KEY,
                    ANTHROPIC_API_KEY = vim.env.ANTHROPIC_API_KEY,
                    OPENAI_API_KEY = vim.env.OPENAI_API_KEY,
                    OPENROUTER_API_KEY = vim.env.OPENROUTER_API_KEY,
                    GEMINI_API_KEY = vim.env.GEMINI_API_KEY,
                    OPENCODE_CONFIG = vim.env.OPENCODE_CONFIG,
                },
            },
        },
    },
    dependencies = {
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
        { "ColinKennedy/mega.cmdparse", dependencies = { "ColinKennedy/mega.logging" } },
    },
}
