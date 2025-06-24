#!/bin/bash

IFACE="eno1"
ACTION="$1"

case "$ACTION" in
  enable)
    echo "[✓] Enabled: delay + packet loss"
    sudo tc qdisc add dev "$IFACE" root netem delay 800ms loss 20%
    ;;
  disable)
    echo "[✓] Disabled network effects"
    sudo tc qdisc del dev "$IFACE" root
    ;;
  status)
    echo "[ℹ️] Current status:"
    sudo tc qdisc show dev "$IFACE"
    ;;
  *)
    echo "Usage: $0 {enable|disable|status}"
    ;;
esac
