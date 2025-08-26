#!/bin/sh
set -eu
STACK="$(/usr/libexec/ha-vrrp/sync/detect_ssh_stack.sh)"
UCI_GET() { uci -q get "$1" 2>/dev/null || true; }
PEER="$(UCI_GET ha_vrrp.core.peer_host)"; CLUSTER="$(UCI_GET ha_vrrp.core.cluster_name)"
[ -z "$CLUSTER" ] && CLUSTER="CLUSTER"; [ -z "$PEER" ] && { echo "[setup_ssh_config] peer_host not set" >&2; exit 1; }
mkdir -p /root/.ssh; chmod 700 /root/.ssh
if [ "$STACK" = "openssh" ] ; then
  CFG="/root/.ssh/config"
  { echo "Host $CLUSTER"; echo "  HostName $PEER"; echo "  User root";
    if [ -f /root/.ssh/id_ed25519 ]; then echo "  IdentityFile /root/.ssh/id_ed25519"; elif [ -f /root/.ssh/id_rsa ]; then echo "  IdentityFile /root/.ssh/id_rsa"; fi
    echo "  StrictHostKeyChecking accept-new"; echo "  UserKnownHostsFile /root/.ssh/known_hosts"; } > "$CFG"
  chmod 600 "$CFG"; echo "[setup_ssh_config] OpenSSH config created for '$CLUSTER' ($PEER)"
else
  echo "[setup_ssh_config] Dropbear in use (dbclient/scp). Keine ~/.ssh/config notwendig."
fi
