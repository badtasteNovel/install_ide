# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Purpose

This repo is a WSL-based Neovim + LazyVim setup toolkit. The scripts install Neovim, configure plugins, and write Lua config files directly into `~/.config/nvim/`.

## Common Commands

```bash
# Full install (deps → lazygit → neovim → lazyvim → php tools → configure)
task

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

`base.Dockerfile` builds the PHP 8.4 base image (`my-php-base:8.4`) used for the distrobox-based PHP environment.

## Key Notes

- `config-mini-surround-lua.sh` incorrectly writes to `telescope.lua` — it overwrites the Telescope config. If both are needed, the files must be merged manually.
- After running any config script, Neovim must be restarted (or `:source` the relevant file) for changes to take effect.
- The Neovide alias for WSL is: `alias nv='"/mnt/c/Program Files/Neovide/neovide.exe" --wsl --neovim-bin /usr/local/bin/nvim'`
- To escape terminal mode in Neovim: `Ctrl+\ Ctrl+N`
- lazygit workspace navigation: `2`/`3` to switch panes, `Ctrl+O` to copy, `Ctrl+C` to exit.
