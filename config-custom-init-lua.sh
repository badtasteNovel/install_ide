#!/bin/bash
set -e

mkdir -p ~/.config/nvim/plugin

cat >~/.config/nvim/plugin/custom-init.lua <<EOF
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
-- 在 init.lua 加入，這會讓游標在 Normal 模式也變薄一點
vim.opt.guicursor = "n-v-c:blinkon0-ver25-Cursor/lCursor"
vim.opt.mouse = ""
-- 1. 先設定 leader 鍵
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- 2. 禁用一些可能衝突的默認行為
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
EOF

echo "✅ custom Lua 配置完成"
