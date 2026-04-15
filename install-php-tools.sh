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

docker create --name ryan-php-extractor "$PHP_IMAGE"
docker cp ryan-php-extractor:"$PHP_INTERNAL_PATH" "$PHP_DIR/php84"
docker cp ryan-php-extractor:/usr/lib/php "$PHP_DIR/extensions"
docker cp ryan-php-extractor:/usr/local/etc/php "$PHP_DIR/etc"
docker rm -f ryan-php-extractor
chmod +x "$PHP_DIR/php84"

echo "正在從 composer:latest 提取 Composer..."
docker create --name ryan-composer-extractor "composer:latest"
docker cp ryan-composer-extractor:/usr/bin/composer "$PHP_DIR/composer"
docker rm -f ryan-composer-extractor
chmod +x "$PHP_DIR/composer"

"$PHP_DIR/php84" -v && "$PHP_DIR/composer" -v && echo "PHP 與 Composer 提取成功！"

# 4. 寫入 Neovim 插件配置
mkdir -p ~/.config/nvim/lua/plugins
cat >~/.config/nvim/lua/plugins/php.lua <<'EOF'
local php_bin_root = "/home/ryan/.local/share/php-bin"
local ryan_php = php_bin_root .. "/php84"

-- 在任何插件載入前就先設好 PATH，確保 phpactor 啟動時能找到 php 和 composer
vim.env.PATH = php_bin_root .. ":" .. vim.env.PATH

return {
  {
    "phpactor/phpactor",
    ft = "php",
    build = function(plugin)
      local cmd = string.format(
        "ln -sf %s %s/php && export PATH=%s:$PATH && %s install --no-dev --optimize-autoloader",
        ryan_php,
        php_bin_root,
        php_bin_root,
        php_bin_root .. "/composer"
      )

      print("正在從私有路徑構建 Phpactor...")
      local output = vim.fn.system(cmd, plugin.dir)
      print(output)
    end,
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
          -- 過濾掉 terminal 視窗
          return vim.bo[buf].buftype ~= "terminal"
        end,
      },
    },
  },
}
EOF

echo "--------------------------------------------------"
echo "配置已更新。請在 Neovim 執行 :Lazy build phpactor"
