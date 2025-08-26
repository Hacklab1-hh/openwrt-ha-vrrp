#!/bin/sh
# PATH: /usr/libexec/ha-vrrp/keysync.sh
# Synchronize authorized_keys to peer using selected SSH backend

set -e
. /usr/lib/ha-vrrp/lib/ssh_backend.sh

PEER_HOST="$(uci -q get ha_vrrp.core.peer_host 2>/dev/null || echo "")"
PEER_USER="$(uci -q get ha_vrrp.core.peer_user 2>/dev/null || echo "root")"
PEER_PORT="$(uci -q get ha_vrrp.core.peer_ssh_port 2>/dev/null || echo "22")"

[ -z "$PEER_HOST" ] && { echo "keysync: peer_host not set"; exit 1; }

AUTHKEYS="/root/.ssh/authorized_keys"
[ -f "$AUTHKEYS" ] || { echo "keysync: $AUTHKEYS missing"; exit 1; }

# Prepare remote .ssh
"$SSH_BIN" -p "$PEER_PORT" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null   "$PEER_USER@$PEER_HOST" "mkdir -p ~/.ssh && chmod 700 ~/.ssh"

# Push authorized_keys
"$SCP_BIN" -P "$PEER_PORT" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null   "$AUTHKEYS" "$PEER_USER@$PEER_HOST:~/.ssh/authorized_keys"

echo "keysync: OK (backend: $SSH_BIN / $SCP_BIN)"
