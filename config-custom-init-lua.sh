#!/bin/bash
set -e

mkdir -p ~/.config/nvim/plugin

cat >~/.config/nvim/plugin/custom-init.lua <<EOF
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.mouse = ""
EOF

echo "✅ custom Lua 配置完成"
