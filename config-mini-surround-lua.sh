#!/bin/bash
set -e

mkdir -p ~/.config/nvim/lua/plugins

cat >~/.config/nvim/lua/plugins/telescope.lua <<EOF
return {
{
    "echasnovski/mini.surround",
    opts = {
      -- 這裡可以自定義快捷鍵，sa 是增加 (Add)，sd 是刪除 (Delete)，sr 是替換 (Replace)
      mappings = {
        add = "sa", -- 增加圍繞
        delete = "sd", -- 刪除圍繞
        find = "sf", -- 尋找圍繞
        find_left = "sF", -- 往左尋找
        highlight = "sh", -- 高亮圍繞
        replace = "sr", -- 替換圍繞
        update_n_lines = "sn", -- 更新行數
      },
    },
    keys = {
      -- 這裡幫你寫一個快捷鍵：按下 <leader>p' 直接貼上剪貼簿內容並包上單引號
      {
        "<leader>p'",
        function()
          local text = vim.fn.getreg("+") -- 獲取系統剪貼簿
          -- 去除換行符號避免格式跑掉
          text = text:gsub("\n", "")
          -- 在當前位置插入包好的文字
          vim.api.nvim_put({ "'" .. text .. "'" }, "c", true, true)
        end,
        desc = "Paste with Single Quotes",
      },
      -- 如果你也想要雙引號的版本
      {
        '<leader>p"',
        function()
          local text = vim.fn.getreg("+")
          text = text:gsub("\n", "")
          vim.api.nvim_put({ '"' .. text .. '"' }, "c", true, true)
        end,
        desc = "Paste with Double Quotes",
      },
    },
  },
}
EOF

echo "✅ mini-surround Lua 配置完成"
