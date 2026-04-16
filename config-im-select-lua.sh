#!/bin/bash
set -e

mkdir -p ~/.config/nvim/lua/plugins

cat >~/.config/nvim/lua/plugins/im-select.lua <<'EOF'
return {
  "keaising/im-select.nvim",   -- ✅ 正確的 repo
    config = function()
      require("im_select").setup {
        default_im_select = "1033",  -- Normal 模式下英文
        set_previous_events = {"InsertLeave"},    -- 插入模式也保持英文
      }
    end,
}
EOF

echo "✅ im-select 插件配置完成 (plugins/im-select.lua)"
