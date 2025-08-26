#!/bin/sh
# PATH: /usr/libexec/ha-vrrp/syncpush.sh
# Example: push keepalived.conf or relevant runtime files to peer using selected SSH backend.

set -e
. /usr/lib/ha-vrrp/lib/ssh_backend.sh

PEER_HOST="$(uci -q get ha_vrrp.core.peer_host 2>/dev/null || echo "")"
PEER_USER="$(uci -q get ha_vrrp.core.peer_user 2>/dev/null || echo "root")"
PEER_PORT="$(uci -q get ha_vrrp.core.peer_ssh_port 2>/dev/null || echo "22")"
REMOTE_DIR="$(uci -q get ha_vrrp.core.peer_sync_dir 2>/dev/null || echo "/etc/keepalived")"

[ -z "$PEER_HOST" ] && { echo "syncpush: peer_host not set"; exit 1; }

SRC="/etc/keepalived/keepalived.conf"
[ -f "$SRC" ] || { echo "syncpush: $SRC missing"; exit 1; }

# Ensure remote dir exists
"$SSH_BIN" -p "$PEER_PORT" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null   "$PEER_USER@$PEER_HOST" "mkdir -p '$REMOTE_DIR'"

# Push file
"$SCP_BIN" -P "$PEER_PORT" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null   "$SRC" "$PEER_USER@$PEER_HOST:$REMOTE_DIR/keepalived.conf"

echo "syncpush: OK (backend: $SSH_BIN / $SCP_BIN)"
