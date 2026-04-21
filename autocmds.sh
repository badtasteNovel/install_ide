#!/bin/bash

# 定義目標路徑
TARGET_FILE="$HOME/.config/nvim/lua/config/autocmds.lua"

echo "🚀 正在更新 Neovim 自動觸發腳本配置..."

# 使用 cat 產生內容，並透過 tee 寫入 (不需要 sudo，因為是在家目錄)
cat <<EOF | tee "$TARGET_FILE" >/dev/null
vim.api.nvim_create_autocmd("FileType", {
  pattern = "php",
  callback = function()
    -- 將 - 和 > 加入關鍵字定義
    vim.opt_local.iskeyword:append("-")
    vim.opt_local.iskeyword:append(">")
    vim.opt_local.iskeyword:append("$")
  end,
})
EOF
echo "✅ 自動腳本配置已更新！請重啟 Neovim 生效。"
