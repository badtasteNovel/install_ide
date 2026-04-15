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

# 強制指定正確的 conf.d 路徑 (改成 8.4)
export PHP_INI_SCAN_DIR=/etc/php/8.4/cli/conf.d

# 安裝 PHP (官方整合包)
echo "📦 安裝 PHP..."
sudo apt update
sudo apt install -y software-properties-common
sudo add-apt-repository -y ppa:ondrej/php
sudo apt update

# 安裝 PHP 8.4 核心
sudo apt install -y php8.4 php8.4-cli php8.4-fpm

# 安裝 Composer
sudo apt install -y composer

# 移除不需要的 Apache 模組
sudo apt remove --purge -y apache2 libapache2-mod-php8.3 || true
sudo apt autoremove -y

# 安裝常用 extensions
sudo apt install -y php8.4-mbstring php8.4-intl php8.4-xml php8.4-zip \
  php8.4-curl php8.4-gd php8.4-pgsql php8.4-bcmath php8.4-redis

# 確認版本
php -v
composer -V

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

-- 使用系統的 conf.d 來載入 apt 安裝的 extensions
vim.env.PATH = php_bin_root .. ":" .. vim.env.PATH
vim.env.PHP_INI_SCAN_DIR = "/etc/php/8.4/cli/conf.d"

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
