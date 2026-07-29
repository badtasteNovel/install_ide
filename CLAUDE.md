# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Purpose

This repo is a WSL-based Neovim + LazyVim setup toolkit. The scripts install Neovim, configure plugins, and write Lua config files directly into `~/.config/nvim/`.

## Common Commands

```bash
# Full install (deps → lazygit → neovim → lazyvim → php tools → configure)
task

# 依 meta.json 的 php-version 更新所有版本相關設定（apt 套件、nvim 設定、Docker base image）
task update

# Apply only keymaps config
task keymaps-config

# Run individual config scripts directly
bash config-php-lua.sh        # requires .env to be present
bash config-telescope-lua.sh
bash config-git-diff.sh
bash config-mini-surround-lua.sh
bash config-auto-tag-lua.sh
bash config-custom-init-lua.sh
bash autocmds.sh
bash keymaps.sh

# Reset all Neovim config (destructive — task will prompt for confirmation)
task clean
```

Install `task` first if not present:
```bash
bash ./install-task.sh
```

## Architecture

Each `config-*.sh` script embeds Lua code via heredoc and writes it to a specific file under `~/.config/nvim/`:

| Script | Target file |
|---|---|
| `config-php-lua.sh` | `~/.config/nvim/lua/plugins/php.lua` |
| `config-telescope-lua.sh` | `~/.config/nvim/lua/plugins/telescope.lua` |
| `config-git-diff.sh` | `~/.config/nvim/lua/plugins/git-diff.lua` |
| `config-mini-surround-lua.sh` | `~/.config/nvim/lua/plugins/telescope.lua` (overwrites!) |
| `config-auto-tag-lua.sh` | `~/.config/nvim/lua/plugins/auto-tag.lua` |
| `config-custom-init-lua.sh` | `~/.config/nvim/plugin/custom-init.lua` |
| `keymaps.sh` | `~/.config/nvim/lua/config/keymaps.lua` |
| `autocmds.sh` | `~/.config/nvim/lua/config/autocmds.lua` |

`config-php-lua.sh` reads `.env` for `PHP_DIR` (path to local PHP binary at `~/.local/share/php-bin`) and interpolates it into the Lua output.

`meta.json` (`{"php-version": "8.5"}`) is the single source of truth for the PHP version. `Taskfile.yaml` reads it into the `PHP_VERSION` var (via `jq`) and threads it through to: `software/install-php.yaml` (apt package names), `config-php-lua.sh` (`PHP_INI_SCAN_DIR`, passed as an env var), the `install-php-tools` task's generated `php.lua`, and `build-php-image` (Docker `--build-arg`). Bumping the PHP version means editing `meta.json` then running `task update` — do not hardcode a version number anywhere else.

`base.Dockerfile` builds the PHP base image (`my-php-base:<version>`) used for the distrobox-based PHP environment; the version comes from `ARG PHP_VERSION`, supplied by `task build-php-image`.

## Key Notes

- `config-mini-surround-lua.sh` incorrectly writes to `telescope.lua` — it overwrites the Telescope config. If both are needed, the files must be merged manually.
- After running any config script, Neovim must be restarted (or `:source` the relevant file) for changes to take effect.
- The Neovide alias for WSL is: `alias nv='"/mnt/c/Program Files/Neovide/neovide.exe" --wsl --neovim-bin /usr/local/bin/nvim'`
- To escape terminal mode in Neovim: `Ctrl+\ Ctrl+N`
- lazygit workspace navigation: `2`/`3` to switch panes, `Ctrl+O` to copy, `Ctrl+C` to exit.
