#!/bin/bash
set -e

mkdir -p ~/.config/nvim/plugin

cat >~/.config/nvim/lua/plugins/git-diff.lua <<EOF
return {
  "sindrets/diffview.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  cmd = {
    "DiffviewOpen",
    "DiffviewClose",
    "DiffviewToggleFiles",
    "DiffviewFocusFiles",
    "DiffviewFileHistory",
  },
  config = function()
    require("diffview").setup()
  end,
}
EOF

echo "✅ git diff Lua 配置完成"
