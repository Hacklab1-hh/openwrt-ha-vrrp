#!/bin/sh
# --- repo root autodetect (robust) ---
ROOT_HINT="$(dirname -- "$0")"
ROOT_DIR="$(CDPATH= cd -- "$ROOT_HINT"/../.. && pwd)"
if [ ! -f "$ROOT_DIR/config/upgradepath.unified.json" ]; then
  ROOT_DIR="$(CDPATH= cd -- "$ROOT_HINT"/.. && pwd)"
fi
if [ ! -f "$ROOT_DIR/config/upgradepath.unified.json" ]; then
  ROOT_DIR="$(CDPATH= cd -- "$ROOT_HINT" && pwd)"
fi
export ROOT_DIR

# install_v0.5.13.sh - robust installer for openwrt-ha-vrrp v0.5.13
# - installs IPKs if present, else overlays files to /
# - detects repo root automatically (no hardcoded path)
set -eu

PKG_VER="0.5.13"
echo "[install] Starting installer for openwrt-ha-vrrp v$PKG_VER"

# Detect repo root (directory one level above this script)
SELF="$(readlink -f "$0" 2>/dev/null || realpath "$0")"
SCRIPTDIR="$(dirname "$SELF")"
REPO_ROOT="$(cd "$SCRIPTDIR/.." && pwd)"
echo "[install] Repo root: $REPO_ROOT"

IPK_DIR_CANDIDATES="\
$REPO_ROOT/../ipk_0_5_13 \
$REPO_ROOT/ipk_0_5_13 \
/tmp \
$REPO_ROOT"
HA_IPK="ha-vrrp_${PKG_VER}-1_all.ipk"
LUCI_IPK="luci-app-ha-vrrp_${PKG_VER}-1_all.ipk"

install_ipks() {
  for d in $IPK_DIR_CANDIDATES; do
    if [ -f "$d/$HA_IPK" ] && [ -f "$d/$LUCI_IPK" ]; then
      echo "[install] Installing IPKs from $d"
      opkg update || true
      opkg install "$d/$HA_IPK" "$d/$LUCI_IPK"
      return 0
    fi
  done
  return 1
}

overlay_copy() {
  echo "[install] IPKs not found, proceeding with overlay copy..."
  # Copy ha-vrrp files/
  if [ -d "$REPO_ROOT/ha-vrrp/files" ]; then
    (cd "$REPO_ROOT/ha-vrrp/files" && tar cf - .) | (cd / && tar xvf -)
  else
    echo "[install] WARN: $REPO_ROOT/ha-vrrp/files not found"
  fi

  # Copy LuCI luasrc -> /usr/lib/lua/luci/..
  if [ -d "$REPO_ROOT/luci-app-ha-vrrp/luasrc" ]; then
    mkdir -p /usr/lib/lua/luci
    (cd "$REPO_ROOT/luci-app-ha-vrrp/luasrc" && tar cf - .) | (cd /usr/lib/lua/luci && tar xvf -)
  else
    echo "[install] WARN: $REPO_ROOT/luci-app-ha-vrrp/luasrc not found"
  fi
}

post_install() {
  # enable/restart services if present
  [ -x /etc/init.d/ha-vrrp ] && /etc/init.d/ha-vrrp enable >/dev/null 2>&1 || true
  [ -x /etc/init.d/ha-vrrp ] && /etc/init.d/ha-vrrp restart >/dev/null 2>&1 || true
  [ -x /etc/init.d/ha-vrrp-syncd ] && /etc/init.d/ha-vrrp-syncd enable >/dev/null 2>&1 || true
  [ -x /etc/init.d/ha-vrrp-syncd ] && /etc/init.d/ha-vrrp-syncd restart >/dev/null 2>&1 || true
  [ -x /etc/init.d/rpcd ] && /etc/init.d/rpcd restart >/dev/null 2>&1 || true
  [ -x /etc/init.d/uhttpd ] && /etc/init.d/uhttpd restart >/dev/null 2>&1 || true

  # Apply keepalived config if tool exists
  if command -v ha-vrrp-apply >/dev/null 2>&1; then
    ha-vrrp-apply || true
    [ -x /etc/init.d/keepalived ] && /etc/init.d/keepalived restart >/dev/null 2>&1 || true
  fi
}

if install_ipks; then
  echo "[install] IPK installation done."
else
  overlay_copy
fi

# Sanity check
if [ ! -f /etc/config/ha_vrrp ]; then
  echo "[install] WARN: /etc/config/ha_vrrp missing after install"
fi

# Report instances (if any)
if command -v uci >/dev/null 2>&1; then
  INST_CNT="$(uci show ha_vrrp 2>/dev/null | grep -cE '^ha_vrrp\.[^.]+=instance' || true)"
  echo "[ha-vrrp] instances found: ${INST_CNT:-0}"
fi

post_install
echo "[install] Done."
