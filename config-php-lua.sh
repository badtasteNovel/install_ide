#!/bin/bash
set -e

# 載入環境變數
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
else
  echo "錯誤：找不到 .env 檔案"
  exit 1
fi

PHP_VERSION="${PHP_VERSION:-$(jq -r '.["php-version"]' meta.json)}"

mkdir -p ~/.config/nvim/lua/plugins

cat >~/.config/nvim/lua/plugins/php.lua <<EOF
local php_bin_root = "${PHP_DIR}"
local ryan_php = php_bin_root .. "/php"

vim.env.PATH = php_bin_root .. ":" .. vim.env.PATH
vim.env.PHP_INI_SCAN_DIR = "/etc/php/${PHP_VERSION}/cli/conf.d"

return {
  -- LSP 整合
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        phpactor = {
          -- 在 language-server 後面加上 -vvv 參數
          cmd = { ryan_php, "${HOME}/.local/share/nvim/lazy/phpactor/bin/phpactor", "language-server", "-vvv" },
          settings = {
            phpactor = {
              -- 強制排除專案中的前端節點與打包目錄，避免 phpactor 跑去爬 Vue 的 node_modules 導致死鎖
              navigator = {
                exclude_paths = { "node_modules/**", "vendor/**", "storage/**", "public/build/**", "dist/**" }
              }
            }
          }
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
      vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { desc = 'Rename' })
    end,
  },
}
EOF

echo "✅ Phpactor Lua 配置完成（已優化 Timeout 與排除路徑）"
