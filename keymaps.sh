#!/bin/bash

# 定義目標路徑
TARGET_FILE="$HOME/.config/nvim/lua/config/keymaps.lua"

echo "🚀 正在更新 Neovim 快捷鍵配置..."

# 使用 cat 產生內容，並透過 tee 寫入 (不需要 sudo，因為是在家目錄)
cat <<EOF | tee "$TARGET_FILE" >/dev/null
-- 由 Ryan 的自動化腳本生成
local keymap = vim.keymap

-- 1. 強制修正 gd (跳轉定義) 為立即執行，不等待其他組合鍵
keymap.set("n", "gd", function()
    vim.lsp.buf.definition()
end, { desc = "Go to Definition (Immediate)", noremap = true, silent = true })

-- 2. 強制修正 gr (查看引用)，跳過反紅，直接打開列表
keymap.set("n", "gr", function()
    vim.lsp.buf.references()
end, { desc = "Show References (LSP Native)", noremap = true, silent = true })

-- 3. 保留你腳本中原有的 Phpactor 快捷鍵 (整合進來)
-- 這裡利用 FileType 自動觸發，確保 PHP 環境下才生效
vim.api.nvim_create_autocmd("FileType", {
    pattern = "php",
    callback = function()
        local opts = { buffer = true, noremap = true, silent = true }
        keymap.set("n", "<leader>cu", "<cmd>PhpactorImportClass<cr>", opts)
        keymap.set("n", "<leader>cn", "<cmd>PhpactorContextMenu<cr>", opts)
    end,
})

-- 4. 其他常用的 Ryan 專屬快捷鍵
keymap.set("n", "<leader>w", ":w<cr>", { desc = "Save" })     -- 空白鍵+w 快速存檔
keymap.set("n", "<leader>q", ":q<cr>", { desc = "Quit" })     -- 空白鍵+q 快速退出

print("✅ 快捷鍵配置已更新！請重啟 Neovim 生效。")
EOF
