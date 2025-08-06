#!/bin/bash

IFACE="eno1"
ACTION="$1"
DELAY="$2"
LOSS="$3"

case "$ACTION" in
  enable)
    if [[ -z "$DELAY" || -z "$LOSS" ]]; then
    echo "Failed, no args"
    exit 1
	fi
    echo "Enabled: delay ${DELAY}ms + packet loss ${LOSS}"
    sudo tc qdisc add dev "$IFACE" root netem delay ${DELAY}ms loss ${LOSS}%
    ;;
  disable)
    echo "Disabled network effects"
    sudo tc qdisc del dev "$IFACE" root
    ;;
  status)
    echo "Current status:"
    sudo tc qdisc show dev "$IFACE"
    ;;
  *)
    echo "Usage:"
    echo "  $0 enable <delay_ms> <loss_percent>"
    echo "  $0 disable"
    echo "  $0 status"
    ;;
esac
