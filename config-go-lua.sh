#!/bin/bash
set -e

# ---------------------------------------------------------------------------
# 1. 透過 lazyvim.json 啟用 LazyVim 內建的 Go extra（lang.go）
#    這樣 import 順序才會正確：lazyvim.plugins -> extras -> 你自己的 plugins
#    （直接在 lua/plugins/*.lua 裡寫 { import = "...extras.lang.go" } 會被
#     LazyVim 抱怨順序不對）
# ---------------------------------------------------------------------------
LAZYVIM_JSON="$HOME/.config/nvim/lazyvim.json"
GO_EXTRA="lazyvim.plugins.extras.lang.go"

if [ -f "$LAZYVIM_JSON" ]; then
  tmp="$(mktemp)"
  jq --arg e "$GO_EXTRA" '.extras = ((.extras // []) + [$e] | unique)' \
    "$LAZYVIM_JSON" >"$tmp" && mv "$tmp" "$LAZYVIM_JSON"
else
  printf '{\n  "extras": ["%s"],\n  "install_version": 8,\n  "version": 8\n}\n' \
    "$GO_EXTRA" >"$LAZYVIM_JSON"
fi

# ---------------------------------------------------------------------------
# 2. 把 Go 工具鏈目錄補進 nvim 的 PATH（寫進 lua/config/options.lua，lazy 載入前執行）
#    GUI（Neovide / Windows 捷徑）啟動的 nvim 不會 source 登入 shell，PATH 常缺
#    ~/go/bin、/usr/local/go/bin 等目錄 → gopls 執行不到 `go`，整個 workspace 載
#    不起來，畫面上所有 Go 符號變成 "undefined"。從終端機 `nvim` 開沒事、從
#    Neovide 開就爆，就是這個原因。
# ---------------------------------------------------------------------------
OPTIONS_FILE="$HOME/.config/nvim/lua/config/options.lua"
mkdir -p "$(dirname "$OPTIONS_FILE")"
if ! grep -q 'go-path-repair' "$OPTIONS_FILE" 2>/dev/null; then
  cat >>"$OPTIONS_FILE" <<'EOF'

-- go-path-repair: GUI 啟動的 nvim PATH 常缺 Go 工具鏈目錄，補回去，
-- 否則 gopls 找不到 `go`、workspace 載不起來、所有 Go 符號變 undefined。
do
  local home = vim.env.HOME or ""
  local candidates = {
    "/usr/local/go/bin",
    home .. "/go/bin",
    home .. "/.local/share/go/bin",
    home .. "/go-workspace/bin",
  }
  for _, dir in ipairs(candidates) do
    if vim.fn.isdirectory(dir) == 1 and not (":" .. (vim.env.PATH or "") .. ":"):find(":" .. dir .. ":", 1, true) then
      vim.env.PATH = dir .. ":" .. (vim.env.PATH or "")
    end
  end
end
EOF
fi

# ---------------------------------------------------------------------------
# 3. 覆寫 gopls 設定，讓「讀 / review Go 程式碼」時被動給出最多資訊
#    * inlay hints：把推斷的型別、參數名、常數值畫在程式碼旁（<leader>uh 切換）
#    * 豐富 hover：K 顯示完整文件與 signature
#    * codelens：函式上方顯示「被誰引用 / run test」
#    * gopls 靜態分析（staticcheck + analyses）當額外的 review 眼睛
#    * treesitter-context：捲動長函式時把外層 func/if/for 釘在畫面頂端
#    不綁任何 <leader> 快捷鍵；能用 go CLI 做的事就用 CLI。
# ---------------------------------------------------------------------------
mkdir -p ~/.config/nvim/lua/plugins

cat >~/.config/nvim/lua/plugins/go.lua <<'EOF'
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = { enabled = true },
      codelens = { enabled = true },
      servers = {
        gopls = {
          settings = {
            gopls = {
              hints = {
                assignVariableTypes = true,
                compositeLiteralFields = true,
                compositeLiteralTypes = true,
                constantValues = true,
                functionTypeParameters = true,
                parameterNames = true,
                rangeVariableTypes = true,
              },
              codelenses = {
                generate = true,
                gc_details = true, -- 逃逸分析 / inline 決策，review 效能時有用
                test = true,
                tidy = true,
                upgrade_dependency = true,
                run_govulncheck = true,
              },
              hoverKind = "FullDocumentation",
              linkTarget = "pkg.go.dev",
              staticcheck = true,
              analyses = {
                fieldalignment = true, -- struct 欄位排列造成的記憶體浪費
                nilness = true,        -- 必定 nil deref 的路徑
                shadow = true,         -- 變數遮蔽
                unusedparams = true,
                unusedwrite = true,
                unusedvariable = true,
                useany = true,
              },
              usePlaceholders = true,
              completeUnimported = true,
              directoryFilters = { "-.git", "-node_modules", "-vendor" },
              semanticTokens = true, -- 更精準的語法高亮
            },
          },
        },
      },
    },
  },

  -- 捲動時把外層 func / if / for 釘在頂端，長函式 review 不會迷路
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "LazyFile",
    opts = { max_lines = 4, multiline_threshold = 1 },
  },
}
EOF

echo "✅ Go Lua 配置完成（lang.go extra 已寫入 lazyvim.json）"
