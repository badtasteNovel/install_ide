#!/bin/bash

# 1. 載入環境變數
if [ -f .env ]; then
  export $(echo $(cat .env | sed 's/#.*//g' | xargs) | envsubst)
  echo "已載入環境變數，使用 Image: $PHP_IMAGE"
else
  echo "錯誤：找不到 .env 檔案"
  exit 1
fi

# 2. 定義私有存放路徑
PHP_DIR="/home/ryan/.local/share/php-bin"
mkdir -p "$PHP_DIR"

# 3. 從變數指定的 Image 提取 PHP
echo "正在從 $PHP_IMAGE 提取 PHP..."

# 建立暫時容器並複製
docker create --name ryan-php-extractor "$PHP_IMAGE"
docker cp ryan-php-extractor:"$PHP_INTERNAL_PATH" "$PHP_DIR/php84"
docker rm -f ryan-php-extractor

# 賦予執行權限
chmod +x "$PHP_DIR/php84"

# 驗證
"$PHP_DIR/php84" -v && echo "PHP 提取成功！"

# 4. 寫入 Neovim 插件配置
mkdir -p ~/.config/nvim/lua/plugins
cat >~/.config/nvim/lua/plugins/php.lua <<'EOF'
local ryan_php = "/home/ryan/.local/share/php-bin/php84"

return {
  {
    "phpactor/phpactor",
    -- 強制使用提取出來的 PHP 進行編譯
    build = ryan_php .. " " .. vim.fn.expand("$HOME") .. "/.local/share/nvim/lazy/phpactor/bin/phpactor install",
    ft = "php",
    config = function()
      vim.g.phpactor_php_bin = ryan_php
      
      -- [需求] 通知 3 秒後自動消失
      local status, notify = pcall(require, "notify")
      if status then
        notify.setup({ timeout = 3000 })
      end

      -- [需求] 視覺模式貼上不污染暫存區 (保留原本剪貼簿內容)
      vim.keymap.set("x", "p", [["_dP]])

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "php",
        callback = function()
          local opts = { buffer = true, silent = true }
          vim.keymap.set("n", "<leader>cu", "<cmd>PhpactorImportClass<cr>", { desc = "PHP Import Class", buffer = true })
          vim.keymap.set("n", "<leader>cn", "<cmd>PhpactorContextMenu<cr>", { desc = "Phpactor Menu", buffer = true })
        end,
      })
    end,
  },
  {
    "akinsho/bufferline.nvim",
    opts = {
      options = {
        custom_filter = function(buf)
          return vim.bo[buf].buftype ~= "terminal"
        end,
      },
    },
  },
}
EOF

echo "配置已更新。請在 Neovim 執行 :Lazy build phpactor"
