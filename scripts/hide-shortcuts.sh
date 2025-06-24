#!/bin/bash

TARGETS=(
  "avahi-discover.desktop"
  "bssh.desktop"
  "bvnc.desktop"
  "qv4l2.desktop"
  "qvidcap.desktop"
  "uxterm.desktop"
  "xterm.desktop"
  "xfce4-about.desktop"
  "thunar-bulk-rename.desktop"
  "thunar-settings.desktop"
  "rofi.desktop"
  "rofi-theme-selector.desktop"
  "compton.desktop"
  "picom.desktop"
  "org.pulseaudio.pavucontrol.desktop"
)

APP_DIR="/usr/share/applications"

for FILE in "${TARGETS[@]}"; do
  FULL_PATH="$APP_DIR/$FILE"
  if [[ -f "$FULL_PATH" ]]; then
    if grep -q "^NoDisplay=" "$FULL_PATH"; then
      sudo sed -i 's/^NoDisplay=.*/NoDisplay=true/' "$FULL_PATH"
    else
      sudo bash -c "echo 'NoDisplay=true' >> \"$FULL_PATH\""
    fi
  fi
done
