#!/bin/sh
set -eu
UCI_GET() { uci -q get "$1" 2>/dev/null || true; }
STACK="$(/usr/libexec/ha-vrrp/sync/detect_ssh_stack.sh)"
PREF_TYPE="$(UCI_GET ha_vrrp.core.key_type)"; [ -z "$PREF_TYPE" ] && PREF_TYPE="auto"
mkdir -p /root/.ssh /etc/ha-vrrp/keys; chmod 700 /root/.ssh
choose_type() {
  case "$PREF_TYPE" in ed25519) echo ed25519;; rsa) echo rsa;;
    *) if command -v ssh-keygen >/dev/null 2>&1 && ssh-keygen -t ed25519 -q -N "" -f /tmp/_t_ed25519 2>/dev/null; then rm -f /tmp/_t_ed25519*; echo ed25519; return; fi
       if command -v dropbearkey >/dev/null 2>&1 && dropbearkey -t ed25519 -f /tmp/_t_db_ed25519 >/dev/null 2>&1; then rm -f /tmp/_t_db_ed25519; echo ed25519; return; fi
       echo rsa;; esac }
TYPE="$(choose_type)"
if [ "$STACK" = "openssh" ]; then
  [ "$TYPE" = ed25519 ] && { [ -f /root/.ssh/id_ed25519 ] || ssh-keygen -t ed25519 -N "" -f /root/.ssh/id_ed25519; }
  [ "$TYPE" = rsa ] && { [ -f /root/.ssh/id_rsa ] || ssh-keygen -t rsa -b 4096 -N "" -f /root/.ssh/id_rsa; }
  chmod 600 /root/.ssh/id_* 2>/dev/null || true; chmod 644 /root/.ssh/id_*.pub 2>/dev/null || true
elif [ "$STACK" = "dropbear" ]; then
  [ "$TYPE" = ed25519 ] && { [ -f /root/.ssh/id_dropbear_ed25519 ] || dropbearkey -t ed25519 -f /root/.ssh/id_dropbear_ed25519; dropbearkey -y -f /root/.ssh/id_dropbear_ed25519 | awk '/^ssh-ed25519/ {print $0}' > /root/.ssh/id_dropbear_ed25519.pub; }
  [ "$TYPE" = rsa ] && { [ -f /root/.ssh/id_dropbear_rsa ] || dropbearkey -t rsa -s 2048 -f /root/.ssh/id_dropbear_rsa; dropbearkey -y -f /root/.ssh/id_dropbear_rsa | awk '/^ssh-rsa/ {print $0}' > /root/.ssh/id_dropbear_rsa.pub; }
  chmod 600 /root/.ssh/id_dropbear_* 2>/dev/null || true; chmod 644 /root/.ssh/id_dropbear_*.pub 2>/dev/null || true
else echo "[generate_keys] ERROR: no SSH client available" >&2; exit 1; fi
PUB="$(ls /root/.ssh/*.pub 2>/dev/null | head -n1 || true)"; [ -n "$PUB" ] && cp -f "$PUB" /etc/ha-vrrp/keys/local_identity.pub || true
