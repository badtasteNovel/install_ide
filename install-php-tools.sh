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
