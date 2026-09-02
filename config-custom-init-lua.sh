#!/bin/bash
set -e

mkdir -p ~/.config/nvim/plugin ~/.config/nvim/lua/config

# leader 鍵必須在 lazy.nvim 載入「之前」設定，所以放進 lua/config/options.lua
# （plugin/*.lua 會在 init.lua 之後才執行，太晚）
OPTIONS_FILE="$HOME/.config/nvim/lua/config/options.lua"
if ! grep -q 'mapleader' "$OPTIONS_FILE" 2>/dev/null; then
  cat >>"$OPTIONS_FILE" <<'EOF'

-- 1. 先設定 leader 鍵（必須在 lazy 載入前）
vim.g.mapleader = " "
vim.g.maplocalleader = " "
EOF
fi

cat >~/.config/nvim/plugin/custom-init.lua <<'EOF'
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
-- 讓游標在 Normal 模式也變薄一點
vim.opt.guicursor = "n-v-c:blinkon0-ver25-Cursor/lCursor"
vim.opt.mouse = ""

-- 禁用一些可能衝突的默認行為
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
EOF

echo "✅ custom Lua 配置完成"
