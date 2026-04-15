#!/bin/bash
set -e

# 載入環境變數
if [ -f .env ]; then
  export $(echo $(cat .env | sed 's/#.*//g' | xargs) | envsubst)
else
  echo "錯誤：找不到 .env 檔案"
  exit 1
fi

# 定義私有存放路徑
PHP_DIR="/home/ryan/.local/share/php-bin"
mkdir -p "$PHP_DIR"

# 安裝 PHP (官方整合包)
echo "📦 安裝 PHP..."
sudo apt update
sudo apt install -y php composer
sudo apt install -y php8.3-mbstring php8.3-intl php8.3-xml php8.3-zip php8.3-curl php8.3-gd php8.3-pgsql php8.3-bcmath php8.3-redis
# 建立 symlink 到私有路徑
ln -sf /usr/bin/php "$PHP_DIR/php"
ln -sf /usr/bin/composer "$PHP_DIR/composer"

# 測試 PHP 與 Composer
"$PHP_DIR/php" -v
"$PHP_DIR/composer" -V

# Neovim Phpactor 配置
mkdir -p ~/.config/nvim/lua/plugins
cat >~/.config/nvim/lua/plugins/php.lua <<'EOF'
local php_bin_root = "/home/ryan/.local/share/php-bin"
local ryan_php = php_bin_root .. "/php"

vim.env.PATH = php_bin_root .. ":" .. vim.env.PATH
vim.env.PHP_INI_SCAN_DIR = php_bin_root .. "/conf.d"

return {
  {
    "phpactor/phpactor",
    ft = "php",
    build = function(plugin)
      local cmd = string.format(
        "export PATH=%s:$PATH && %s install --no-dev --optimize-autoloader",
        php_bin_root,
        php_bin_root .. "/composer"
      )
      vim.fn.system(cmd, plugin.dir)
    end,
    config = function()
      vim.g.phpactor_php_bin = ryan_php
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "php",
        callback = function()
          vim.keymap.set("n", "<leader>cu", "<cmd>PhpactorImportClass<cr>", { buffer = true })
          vim.keymap.set("n", "<leader>cn", "<cmd>PhpactorContextMenu<cr>", { buffer = true })
        end,
      })
    end,
  },
}
EOF
