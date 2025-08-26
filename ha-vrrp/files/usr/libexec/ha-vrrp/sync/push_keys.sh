#!/bin/sh
set -eu
STACK="$(/usr/libexec/ha-vrrp/sync/detect_ssh_stack.sh)"
UCI_GET() { uci -q get "$1" 2>/dev/null || true; }
PEER="$(UCI_GET ha_vrrp.core.peer_host)"; [ -z "$PEER" ] && { echo "[push_keys] peer_host not set" >&2; exit 1; }
PUB="$(ls /root/.ssh/*.pub 2>/dev/null | head -n1 || true)"; [ -z "$PUB" ] && PUB="/etc/ha-vrrp/keys/local_identity.pub"
[ -r "$PUB" ] || { echo "[push_keys] no public key found" >&2; exit 1; }
TMP="/tmp/ha_vrrp_pub_$$.pub"; cp -f "$PUB" "$TMP"
if [ "$STACK" = "openssh" ] && command -v ssh >/dev/null 2>&1 && command -v scp >/dev/null 2>&1; then
  ssh -o StrictHostKeyChecking=accept-new root@"$PEER" 'mkdir -p /root/.ssh && touch /root/.ssh/authorized_keys && chmod 600 /root/.ssh/authorized_keys'
  scp "$TMP" root@"$PEER":/tmp/ha_vrrp_pub_import.pub
  ssh root@"$PEER" 'grep -qxF "$(cat /tmp/ha_vrrp_pub_import.pub)" /root/.ssh/authorized_keys || cat /tmp/ha_vrrp_pub_import.pub >> /root/.ssh/authorized_keys; rm -f /tmp/ha_vrrp_pub_import.pub'
elif command -v dbclient >/dev/null 2>&1; then
  dbclient -y root@"$PEER" 'mkdir -p /root/.ssh && touch /root/.ssh/authorized_keys && chmod 600 /root/.ssh/authorized_keys'
  scp "$TMP" root@"$PEER":/tmp/ha_vrrp_pub_import.pub
  dbclient -y root@"$PEER" 'grep -qxF "$(cat /tmp/ha_vrrp_pub_import.pub)" /root/.ssh/authorized_keys || cat /tmp/ha_vrrp_pub_import.pub >> /root/.ssh/authorized_keys; rm -f /tmp/ha_vrrp_pub_import.pub'
else echo "[push_keys] ERROR: no ssh/scp client available" >&2; exit 1; fi
rm -f "$TMP"
