
```
sudo chown -R $USER:$USER .
```
# git persistent
```
git config --global credential.helper store
```
# 安裝task
```
bash ./install-task.sh
```
# how to escape terminal mode to normal mode
```
ctrl+\ (hold ctrl) ctrl+n
```
# 安裝 nevoide msi 版本(msi: microsoft installer)
# bashrc alias 
```
alias nv='"/mnt/c/Program Files/Neovide/neovide.exe" --wsl --neovim-bin /usr/local/bin/nvim'
```
# 安裝php-actor
```
:MasonInstall phpactor
```
# env 非敏感資訊

# 執行Lazy install phpactor 再執行 Lazy build phpactor

```
cd ~/.local/share/nvim/lazy/phpactor
composer install
```

# 操作
- lazygit: 以 2 3 切換工作區 ， ctrl+o 進行copy ，ctrl+c 進行離開
# html 操作
za：切換 (Toggle) 摺疊狀態。如果現在是開的就收起來，關的就打開。

zc：收起 (Close) 當前區塊。

zo：展開 (Open) 當前區塊。

zM：關閉所有 摺疊（收起全檔案的區塊）。

zR：打開所有 摺疊。
