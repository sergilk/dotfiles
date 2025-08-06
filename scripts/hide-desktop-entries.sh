#!/bin/bash

WHITELIST=(
  "telegram.desktop"
  "discord.desktop"
  "chromium.desktop"
  "code.desktop"
  "com.github.wwmm.easyeffects.desktop"
  "feh.desktop"
  "firefox.desktop"
  "nvidia-settings.desktop"
  "zen.desktop"
  "steam.desktop"
  "thunar.dekstop"
  "spotify.desktop"
  "galculator.desktop"
  "obsidian.desktop"
  "lm-studio.desktop"
)

APP_DIR="/usr/share/applications"

declare -A whitelist_map
for FILE in "${WHITELIST[@]}"; do
  whitelist_map["$FILE"]=1
done

for FILE in "$APP_DIR"/*.desktop; do
  BASENAME=$(basename "$FILE")

  if [[ -z "${whitelist_map[$BASENAME]}" ]]; then
    if grep -q "^NoDisplay=" "$FILE"; then
      sudo sed -i 's/^NoDisplay=.*/NoDisplay=true/' "$FILE"
    else
      sudo bash -c "echo 'NoDisplay=true' >> \"$FILE\""
    fi
  fi
done

