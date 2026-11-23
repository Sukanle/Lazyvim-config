# Neovim Configuration

个人 Neovim 配置，基于 [LazyVim](https://github.com/LazyVim/LazyVim)，面向 C/C++、Rust、Zig 和 Lua 开发。

当前环境：Neovim 0.12.6 / LazyVim 16。

## 环境要求

- Neovim >= 0.11.2
- git、ripgrep、fd、tree-sitter-cli
- clangd、clang-format
- rust-analyzer、rustfmt
- lldb-dap
- Zig 0.17.x、zig-analyzer
- 可选：fish（`platform.lua` 会依次尝试 fish、zsh、bash）
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
│   │   ├── lspconfig.lua        # LSP：clangd / rust-analyzer / zig-analyzer / lua_ls
│   │   ├── conform.lua          # 格式化：clang-format / rustfmt
│   │   ├── treesitter.lua       # Treesitter 额外 parser
│   │   ├── blink.cmp.lua        # 补全
│   │   ├── dap.lua              # DAP adapter 与 launch 配置
│   │   ├── dap-ui.lua           # DAP UI / 虚拟文本
│   │   ├── avante.lua           # AI 助手
│   │   ├── yazi.lua             # 文件管理器
│   │   ├── bufferline.lua       # buffer 标签栏
│   │   ├── lualine.lua          # 状态栏
│   │   └── transparent.lua      # 透明背景
│   ├── i18n/
│   │   ├── init.lua             # locale 检测、词表加载、tr()
│   │   ├── hooks.lua            # 通用 watch/wrap hook 接口
│   │   ├── adapters/            # 按插件拆分的独立适配器
│   │   └── locales/zh_CN/       # 分布式中文词表
│   └── utils/
│       └── file_sync.lua        # 软链接同步工具
├── share/
│   ├── clang-extern-tools/      # 共享的 clangd / clang-format 配置
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
| C/C++ | clangd | 使用 `share/clang-extern-tools/config.yaml`，compile commands 目录为 `build` |
| Rust | rust-analyzer | 开启 clippy、allFeatures、proc macro |
| Zig | zig-analyzer | `zig` / `zon`，使用 `build.zig` / `.git` 作为项目根 |
| Lua | lua_ls | 通过 Mason 安装，包含 xmake 定义 |

clangd 和 clang-format 的共享配置会通过 `lua/utils/file_sync.lua` 软链接到 `~/.config/clangd/`。

### 调试

- 使用 `lldb-dap` 作为 DAP adapter。
- C/C++ 默认启动 `build/<platform>/<machine>/debug/<file>`。
- Rust 默认从 `target/debug/` 选择可执行文件。
- 调试键位、dap-ui 的打开/关闭逻辑复用 LazyVim 的 `dap.core` extra。
- 不自动安装 `codelldb`，避免与 `lldb-dap` 重复。

### 补全与代码片段

- blink.cmp 提供 LSP、path、snippets、buffer 补全。
- 额外启用 Avante、colorful-menu、blink-cmp-words。
- `snippets/` 中的 VSCode 风格片段由 blink.cmp 自动加载。

### 文件与界面

- Yazi：`<leader>-` 打开当前文件所在目录，`<leader>cw` 打开工作目录。
- bufferline + snacks picker + lualine。
- 状态栏有意保持极简，`lualine_c` 和 `lualine_x` 留空。
- 配色使用 LazyVim 默认的 tokyonight moon。
- 透明背景通过 transparent.nvim 处理。

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
- `locales/zh_CN/`：按模块分布式管理词表，可以继续添加 `.lua` 文件，加载时自动合并。

新增词条时，在 `locales/xx_YY/` 下任意文件里添加映射即可：

```lua
-- 简体中文示例
return {
    ["Find Files"] = "查找文件",
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
