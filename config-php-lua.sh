#!/bin/bash
set -e

# 載入環境變數
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
else
  echo "錯誤：找不到 .env 檔案"
  exit 1
fi

mkdir -p ~/.config/nvim/lua/plugins

cat >~/.config/nvim/lua/plugins/php.lua <<EOF
local php_bin_root = "${PHP_DIR}"
local ryan_php = php_bin_root .. "/php"

vim.env.PATH = php_bin_root .. ":" .. vim.env.PATH
vim.env.PHP_INI_SCAN_DIR = "/etc/php/8.4/cli/conf.d"

return {
  -- LSP 整合
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        phpactor = {
          cmd = { ryan_php, "${HOME}/.local/share/nvim/lazy/phpactor/bin/phpactor", "language-server" },
        },
      },
    },
  },

  -- Phpactor 插件
  {
    "phpactor/phpactor",
    ft = "php",
    build = function(plugin)
      local cmd = string.format(
        "export PATH=%s:\$PATH && %s install --no-dev --optimize-autoloader",
        php_bin_root,
        php_bin_root .. "/composer"
      )
      vim.fn.system(cmd, plugin.dir)
    end,
    config = function()
      vim.g.phpactor_php_bin = ryan_php
    end,
  },
}
EOF

echo "✅ Phpactor Lua 配置完成"
