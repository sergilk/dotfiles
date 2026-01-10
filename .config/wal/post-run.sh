#!/usr/bin/env bash

# This is just a wrapper for running post-run scripts

"$HOME/.config/wal/scripts/dunst.sh"
"$HOME/.config/wal/scripts/gtk.py" -f "$HOME/.cache/wal/gtk.css" -t "$HOME/.config"
"$HOME/.config/wal/scripts/obsidian.sh" "$HOME/vault/obsidian/obsidian-vaults/main/.obsidian/snippets/obsidian.css"
