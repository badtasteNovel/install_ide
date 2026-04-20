#!/bin/bash
set -e

mkdir -p ~/.config/nvim/lua/plugins

cat >~/.config/nvim/lua/plugins/telescope.lua <<EOF
return {
    {
        'nvim-telescope/telescope.nvim',
        tag = '0.1.8', -- 建議鎖定版本比較穩定
        dependencies = { 'nvim-lua/plenary.nvim' },
        config = function()
            local builtin = require('telescope.builtin')
            
            -- 設定快捷鍵
            -- 搜尋檔案 (類似 VS Code 的 Ctrl+P)
            vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
            
            -- 全文字搜尋 (Live Grep)
            vim.keymap.set('n', '<leader>sg', builtin.live_grep, {})
            
            -- 搜尋開啟中的 Buffer
            vim.keymap.set('n', '<leader>fb', require('telescope.builtin').lsp_document_symbols, {})
            -- 搜尋全專案的 Function/Symbol (你剛才問的功能)
            vim.keymap.set('n', '<leader>fs', builtin.lsp_dynamic_workspace_symbols, {})
        end
    }
}
EOF

echo "✅ Telescope Lua 配置完成"
