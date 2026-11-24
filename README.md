# Neovim Configuration

个人 Neovim 配置，基于 [LazyVim](https://github.com/LazyVim/LazyVim)，面向 C/C++、Rust、Zig 和 Lua 开发。

当前环境：Neovim 0.12.6 / LazyVim 16。
## 环境要求

- Neovim >= 0.11.2
- git、ripgrep、fd、tree-sitter-cli
- clice（`paru -S clice-bin`，C/C++ LSP、诊断与格式化；项目需提供 `compile_commands.json`）
- clang-format（clice 不可用时的 C/C++ 格式化回退）
- rust-analyzer、rustfmt
- lldb-dap
- Zig 0.17.x、zig-analyzer
- emmylua：`cargo install emmylua_ls emmylua_check emmylua_formatter`（分别提供 `emmylua_ls`、`emmylua_check`、`luafmt`）
- prettier（Markdown / JSON 格式化）
- ruff（Python 格式化）
- ty（Python 类型检查 / LSP）：`uv tool install ty`
- cmakefmt（CMake 格式化）
- 可选：fish（`platform.lua` 会依次尝试 fish、zsh、bash）
- 可选：[libtexprintf](https://github.com/bartp5/libtexprintf)（提供 `utftex`，用于将 LaTeX 转换为 Unicode）
- 可选：[pylatexenc](https://pypi.org/project/pylatexenc/)（提供 `latex2text`，作为 LaTeX 转换的回退）
- render-markdown 的 Treesitter 增强：`html`、`latex`、`yaml`（`treesitter.lua` 会自动安装）
- Nerd Font（图标显示）

## 安装

```sh
git clone git@github.com:Sukanle/Lazyvim-config.git ~/.config/nvim
cd ~/.config/nvim
git submodule update --init share/lua-language-server/LLS-Addons
git -C share/lua-language-server/LLS-Addons submodule update --init addons/xmake/module
nvim
```

只初始化 xmake 补全所需的嵌套子模块，`LLS-Addons` 中的其他 addon 不会下载。

首次启动会自动安装插件。之后按需执行：

```vim
:Lazy
:Mason
:checkhealth
```

Zig Treesitter parser 会在首次启动时自动安装，也可以手动执行 `:TSInstall zig`。

## 目录结构

```text
.
├── init.lua                     # 入口：全局开关、平台信息、lazy.nvim
├── .emmyrc.json                 # EmmyLua 项目配置（$VIMRUNTIME / xmake）
├── lazyvim.json                 # 启用的 LazyVim extras
├── lazy-lock.json               # 插件版本锁
├── lua/
│   ├── config/
│   │   ├── lazy.lua             # lazy.nvim 配置
│   │   ├── platform.lua         # 系统判断、shell、vim.g.home
│   │   ├── options.lua          # 编辑器选项
│   │   ├── keymaps.lua          # 自定义快捷键
│   │   └── autocmds.lua         # 自定义自动命令
│   ├── plugins/
│   │   ├── lspconfig.lua        # LSP：clice / rust-analyzer / zig-analyzer / emmylua_ls / ty
│   │   ├── conform.lua          # 格式化：rustfmt / prettier / cmakefmt / ruff / luafmt
│   │   ├── linting.lua          # Lua linter：emmylua_check
│   │   ├── treesitter.lua       # Treesitter 额外 parser（zig/html/latex/yaml）
│   │   ├── blink.cmp.lua        # 补全
│   │   ├── which-key.lua        # which-key 边框
│   │   ├── colorful-winsep.lua  # 活动窗口圆角边框
│   │   ├── dap.lua              # DAP adapter 与 launch 配置
│   │   ├── dap-ui.lua           # DAP UI / 虚拟文本
│   │   ├── avante.lua           # AI 助手
│   │   ├── yazi.lua             # 文件管理器
│   │   ├── bufferline.lua       # buffer 标签栏
│   │   ├── lualine.lua          # 状态栏
│   │   ├── notifications.lua    # Noice + nvim-notify
│   │   ├── render-markdown.lua  # Markdown 只读预览与跟随
│   │   └── transparent.lua      # 透明背景
│   ├── i18n/
│   │   ├── init.lua             # locale 检测、词表加载、tr()
│   │   ├── hooks.lua            # 通用 watch/wrap hook 接口
│   │   ├── adapters/            # 按插件拆分的独立适配器
│   │   └── locales/zh_CN/       # 分布式中文词表
│   └── utils/
│       ├── clangd.lua           # 旧 clangd 配置同步工具（当前未启用）
│       └── file_sync.lua        # 软链接同步工具
├── share/
│   ├── cpp-analyzer/            # 共享 C/C++ 配置
│   │   ├── .clang-format        # clang-format / clice 格式化风格
│   │   ├── config.toml          # clice 配置（复制/软链到项目 .clice/）
│   │   └── config.yaml          # clangd 回退配置
│   └── lua-language-server/     # LLS-Addons 子模块（xmake 补全）
└── snippets/                    # VSCode 风格代码片段
```

## 功能模块

### 核心

- 以 LazyVim 默认配置为基础，保留其键位、UI 和 LazyExtras 机制。
- 使用 4 空格缩进、全局 `wrap`、圆角浮窗。
- 诊断信息不显示 virtual text，只在行内下划线/符号中展示。
- `vim.g.autoformat = false`：默认不在保存时自动格式化，使用 `<leader>cf` 手动格式化。
- 最多保留 10 个 listed buffer，超出时只关闭未修改的 buffer。

### LSP

| 语言 | Server | 说明 |
| --- | --- | --- |
| C/C++ | clice | 系统安装（`paru -S clice-bin`），需要 `compile_commands.json`；诊断与格式化均由 clice 提供 |
| Rust | rust-analyzer | 开启 clippy、allFeatures、proc macro |
| Zig | zig-analyzer | `zig` / `zon`，使用 `build.zig` / `.git` 作为项目根 |
| Lua | emmylua_ls | 通过 cargo 安装，LuaJIT runtime，包含 xmake 定义 |
| Python | ty | 通过 `uv tool install ty` 安装，`ty server` 提供补全、hover、跳转；诊断由 `ty check` 提供 |

`clangd` 已禁用，由 `clice` 接管 C/C++ 的补全、hover、跳转、诊断和格式化。
`clice` 会从项目根目录或其中直接子目录查找 `compile_commands.json`，根标记为
`clice.toml`、`compile_commands.json`、`.git`。

共享 C/C++ 配置位于 `share/cpp-analyzer/`：

- `.clang-format`：clang-format / clice 的格式化风格
- `config.toml`：clice 配置，由 `config.yaml` 迁移而来
- `config.yaml`：保留的 clangd 回退配置

clice 只读取项目根目录的 `clice.toml` 或 `.clice/config.toml`，因此共享配置需要复制或软链到项目：

```sh
mkdir -p .clice
ln -sf ~/.config/nvim/share/cpp-analyzer/config.toml .clice/config.toml
```

`clangd` 的 `Diagnostics: ClangTidy` 检查项无法写入 `clice.toml`，clice 使用项目最近的 `.clang-tidy`；
`config.toml` 中的 `[diagnostics] clang_tidy` 只负责开关 clang-tidy。

Rust 的 `'`（生命周期）在 `after/ftplugin/rust.lua` 中禁用 mini.pairs 自动配对。
Lua 的 `lua_ls` 已禁用，由 `emmylua_ls` 接管补全、hover、代码操作等能力。

Neovim API（`vim.*`）只在当前仓库生效：根目录的 `.emmyrc.json` 通过 `$VIMRUNTIME`
把 Neovim runtime 作为 library，并加入 xmake 定义。其他 Lua 项目不会加载该 library，
因此不会出现 `vim` 补全，也不会把 `vim` 当作已定义的全局变量。

如果其他 Neovim 插件/配置项目也需要 `vim` API，在该项目根目录添加同样带
`"library": ["$VIMRUNTIME"]` 的 `.emmyrc.json` 即可，不需要修改全局 LSP 配置。

### 格式化与检查

| 文件类型 | 工具 |
| --- | --- |
| C / C++ | `clice`（LSP `textDocument/formatting`），回退 `clang-format` |
| Rust | `rustfmt` |
| Zig | `zig fmt` |
| Markdown | `prettier` |
| CMake | `cmakefmt` |
| Python | `ruff`（organize imports + format） |
| JSON | `prettier` |
| Lua | `luafmt`（`emmylua_formatter`） |

`vim.g.autoformat = false`，因此保存时不会自动格式化，需要手动执行 `<leader>cf`。

C/C++ 使用 per-filetype 的 `lsp_format = "prefer"`：`<leader>cf` 优先使用 clice 的 LSP 格式化；
当没有可用的格式化 LSP 客户端时，回退到 conform 的 `clang-format`。

```lua
["c"] = { "clang-format", lsp_format = "prefer" },
["cpp"] = { "clang-format", lsp_format = "prefer" },
```

clice 使用文件所在目录向上最近的 `.clang-format`；当前项目根目录已有该文件。
`clice lint` 可对项目运行 clang-tidy，但它是全项目扫描，没有接入 `nvim-lint`。

Python 的诊断由 `ty check` 通过 `nvim-lint` 提供（`--output-format gitlab`），
并根据 buffer 路径自动定位 `pyproject.toml` / `ty.toml` 作为 `--project`。
`ty` LSP 动态注册的 pull diagnostics 会被过滤，避免同一条诊断出现两次；LSP 仍负责补全、hover、跳转和代码操作。

Lua 的诊断由 `emmylua_check` 通过 `nvim-lint` 提供（在 BufReadPost / InsertLeave / BufWritePost 触发）。
它以项目根为 workspace 运行，会读取该项目的 `.emmyrc.json`，因此 `vim` API 和 xmake 定义同样只在当前仓库生效。
`emmylua_ls` 自身的诊断已关闭，避免与 `emmylua_check` 产生重复条目；LSP 仍负责补全、hover、跳转和代码操作。

### 调试

- 使用 `lldb-dap` 作为 DAP adapter。
- C/C++ 默认启动 `build/<platform>/<machine>/debug/<file>`。
- Rust 默认从 `target/debug/` 选择可执行文件。
- 调试键位、dap-ui 的打开/关闭逻辑复用 LazyVim 的 `dap.core` extra。
- 不自动安装 `codelldb`，避免与 `lldb-dap` 重复。

### 补全与代码片段

- blink.cmp 提供 LSP、path、snippets、buffer 补全。
- 额外启用 [Avante](https://github.com/yetone/avante.nvim)、colorful-menu、blink-cmp-words。
- Avante 使用 OpenCode ACP（`opencode acp`），API Key 只从 `OPENCODE_API_KEY` 等环境变量读取。
- Avante 默认启用；在 `lua/config/options.lua` 设置 `opts.ai.avante = false` 可关闭。
- `snippets/` 中的 VSCode 风格片段由 blink.cmp 自动加载。

### 文件与界面

- Yazi：`<leader>-` 打开当前文件所在目录，`<leader>cw` 打开工作目录。
- bufferline + snacks picker + lualine。
- 状态栏有意保持极简，`lualine_c` 和 `lualine_x` 留空。
- Noice 通知改用 `nvim-notify` 后端，使用 `fade_in_slide_out` 动画。
- `nvim-notify` 的 `Notify*Body` / `NotifyBackground` 背景在 `transparent.lua` 中清空，保持通知透明。
- Markdown 源文件默认不渲染；`<leader>md` 打开右侧只读预览，并跟随活动 Markdown buffer。
- Markdown 源文件使用 `conceallevel=0`，不隐藏 `*` 等标记；预览 buffer 使用 `conceallevel=3`。
- 配色使用 LazyVim 默认的 tokyonight moon。
- 透明背景通过 transparent.nvim 处理。

### 边界与分隔符

统一使用 cmdline 风格的圆角边框和线条分隔：

- 浮动窗口：`winborder = "rounded"`，使用 `╭─╮` / `╰─╯`
- 横向分屏：`fillchars.horiz = "─"`
- 纵向分屏：`fillchars.vert = "│"`
- 分屏交叉点：`┴`、`┬`、`┤`、`├`、`┼`
- lualine / bufferline：使用 `│` 分隔
- 活动窗口：`colorful-winsep.nvim` 在窗口边界绘制 `╭─╮` 圆角边框
- which-key：单独启用 `border = "rounded"`
- Lazy 插件管理 / LazyExtras：`lazy.nvim` 的 `ui.border = "rounded"`，并使用 `backdrop = false`
- LazyVim 更新日志（`<leader>L`）：Snacks `news` 样式增加 `border = "rounded"`
- Snacks picker、Blink、LSP hover 等继承 `winborder`

对应配置在：

```text
lua/config/options.lua
lua/config/lazy.lua
lua/plugins/lualine.lua
lua/plugins/bufferline.lua
lua/plugins/which-key.lua
lua/plugins/colorful-winsep.lua
lua/plugins/snacks.lua
```

### I18N 适配

`lua/i18n/` 是一个轻量本地化层，使用 `英文原文 -> 译文` 模式：

- `init.lua`：默认 `locale = "auto"`，按 `LC_ALL` > `LC_MESSAGES` > `LANG` 自动检测；也可以通过 `vim.g.i18n_locale` 手动指定。`en` / `en_US` / `en_UK` / `C` / `POSIX` 会直接使用英文原文，跳过词表加载和 hook。加载词表后提供 `require("i18n").tr()`。
- `hooks.lua`：通用 hook 接口：
  - `hooks.watch(module, callback)`：等模块被真正加载后再执行回调，不会提前 `require` 插件
  - `hooks.wrap(module, method, make)`：包装插件方法，并自动记录撤销函数
  - `hooks.stop()`：撤销所有 hook
- `adapters/`：每个插件一个独立适配器，自动发现并注册。目前包括：
  - `keymap.lua`：拦截 `nvim_set_keymap` / `nvim_buf_set_keymap`，翻译快捷键 `desc`
  - `which-key.lua`：包装 `which-key.view.replace` 和 `which-key.text.append`
  - `snacks.lua`：包装 picker 标题模板和 dashboard 渲染
- `lualine` 的模式名通过 `lualine_a.fmt` 翻译，保持原始 `get_mode()` 供主题选择颜色
- `noice` 的 cmdline 标题在 `lua/plugins/notifications.lua` 中本地化
- `locales/zh_CN/`：按模块分布式管理词表，可以继续添加 `.lua` 文件，加载时自动合并。
  - `ui.lua`：模式名等内置 UI 文本
  - `keymaps.lua`：快捷键描述
  - `which-key.lua` / `snacks.lua`：插件适配词表

新增词条时，在 `locales/xx_YY/` 下任意文件里添加映射即可：

```text
locales/xx_YY/
├── ui.lua                       # 内置UI词表
├── keymaps.lua                  # 内置快捷键词表
└── <plugins-adapters>.lua       # 插件(需注册adapters)专用词表
```

1. `Lazyvim/Neovim` 内置UI:

```lua
-- 简体中文示例
-- lua/i18n/locales/zh_CN/ui.lua
return {
    ["Normal"] = "普通模式",
}
```

2. `Lazyvim/Neovim` 内置快捷键:

```lua
-- 简体中文示例
-- lua/i18n/locales/zh_CN/keymad.lua
return {
    ["Find Files"] = "查找文件",
}
```

3. 插件(需注册adapters)专用词表:

```lua
-- 简体中文示例
-- lua/i18n/locales/zh_CN/which-key.lua
return {
    ["tabs"] = "标签页",
}
```

新增插件适配器时，在 `adapters/` 下创建独立文件：

```lua
-- lua/i18n/adapters/my-plugin.lua
return {
    setup = function(i18n, hooks)
        hooks.watch("my-plugin.view", function(view)
            hooks.wrap(view, "render", function(original)
                return function(...)
                    local text = original(...)
                    return i18n.tr(text)
                end
            end)
        end)
    end,
}
```

没有对应词条时自动回退英文。新增语言时创建 `locales/<locale>/` 目录即可，例如 `locales/zh_TS/`。

默认自动检测：

```lua
vim.g.i18n_locale = "auto"
```

手动指定中文：

```lua
vim.g.i18n_locale = "zh_CN"
```

英文环境直接使用英文原文，不加载词表和 adapter：

```lua
vim.g.i18n_locale = "en_US" -- 或 en_UK
```

临时关闭 I18N 适配：

```lua
vim.g.i18n_enabled = false
```

## 常用快捷键

| 快捷键 | 功能 |
| --- | --- |
| `<leader>fc` | 切换到 Neovim 配置目录并打开 `init.lua` |
| `<leader>md` | 用 render-markdown 在垂直分屏预览 Markdown（只读、跟随活动 Markdown buffer） |
| `<leader>cf` | 格式化当前 buffer |
| `<leader>-` | 用 Yazi 打开当前文件所在目录 |
| `<leader>cw` | 用 Yazi 打开工作目录 |
| `<C-Up>` | 恢复上一次 Yazi 会话 |
| `<leader>db` | 切换断点 |
| `<leader>dc` | 运行/继续 |
| `<leader>du` | 打开/关闭 DAP UI |
| `<leader>da` | 带参数运行 |

其余 LSP、Git、搜索、Snacks picker 键位沿用 LazyVim 默认，可用 `<leader>?` 或 which-key 查看。

## 维护

```vim
:Lazy          " 插件管理
:LazyExtras    " LazyVim extras
:Mason         " LSP / formatter / DAP 工具
:checkhealth   " 健康检查
```

配置按模块拆分在 `lua/config` 和 `lua/plugins` 下，新增功能时优先放到独立模块，避免单个文件持续膨胀。
