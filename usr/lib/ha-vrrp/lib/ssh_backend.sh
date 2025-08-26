#!/bin/sh
# PATH: /usr/lib/ha-vrrp/lib/ssh_backend.sh
# Picks SSH/SCP binaries based on UCI option ha_vrrp.core.ssh_backend

SSH_BIN="ssh"
SCP_BIN="scp"

pick_backend() {
  local backend
  backend="$(uci -q get ha_vrrp.core.ssh_backend 2>/dev/null || echo auto)"
  case "$backend" in
    dropbear)
      if command -v dbclient >/dev/null 2>&1; then SSH_BIN="dbclient"; else SSH_BIN="ssh"; fi
      if command -v scp >/dev/null 2>&1; then SCP_BIN="scp"; else SCP_BIN="scp"; fi
      ;;
    openssh)
      SSH_BIN="ssh"
      SCP_BIN="scp"
      ;;
    auto|*)
      if command -v ssh >/dev/null 2>&1 && command -v scp >/dev/null 2>&1; then
        SSH_BIN="ssh"; SCP_BIN="scp"
      elif command -v dbclient >/dev/null 2>&1; then
        SSH_BIN="dbclient"; SCP_BIN="scp"
      else
        SSH_BIN="ssh"; SCP_BIN="scp"
      fi
      ;;
  esac
}

pick_backend
export SSH_BIN SCP_BIN
