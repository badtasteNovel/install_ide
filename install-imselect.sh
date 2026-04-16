#!/usr/bin/env bash
source .env
set -euo pipefail

# 用 gum choose 選擇作業系統
os=$(gum choose "Windows" "macOS" "Linux")

echo "選擇的作業系統: $os"

case "$os" in
"Windows")
  echo "下載 im-select.exe 到 Windows 使用者目錄"
  curl -L -o /tmp/im-select.exe \
    https://github.com/daipeihust/im-select/releases/latest/download/im-select.exe

  echo "cp 檔案到 /mnt/c/Users/user/bin"
  cp /tmp/im-select.exe /mnt/c/$USER_PATH/im-select.exe
  sudo ln -sf /mnt/c/$USER_PATH/im-select.exe /usr/local/bin/im-select
  ;;

"macOS")
  echo "使用 brew 安裝 im-select"
  brew install im-select
  ;;

"Linux")
  echo "在 WSL 直接下載 im-select.exe 到 /usr/local/bin"
  sudo curl -L \
    -o /usr/local/bin/im-select \
    https://github.com/daipeihust/im-select/releases/latest/download/im-select.exe
  sudo chmod +x /usr/local/bin/im-select

  echo "安裝 fcitx5 或 ibus 以確保輸入法切換正常"
  sudo apt update
  sudo apt install -y fcitx5 fcitx5-config-qt
  ;;
esac

echo "完成安裝與設定"
