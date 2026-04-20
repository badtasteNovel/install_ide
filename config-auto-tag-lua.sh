#!/bin/bash
set -e

mkdir -p ~/.config/nvim/lua/plugins

cat >~/.config/nvim/lua/plugins/auto-tag.lua <<EOF
return {
  {
    "windwp/nvim-ts-autotag",
    dependencies = "nvim-treesitter/nvim-treesitter",
    config = function()
      require("nvim-ts-autotag").setup()
    end,
  },
}
EOF

echo "✅ auto-tag Lua 配置完成"
