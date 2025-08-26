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

# install_legacy_compatible.sh – CLI-verträglich zum Ur-Installer (ohne Flags, interaktiv-frei)
# Verhalten: Bestehende Pakete prüfen, keepalived/ip-full/uci/luci installieren, dann HA-Dateien kopieren,
# Dienste starten. Nutzt opkg; wenn nicht verfügbar, Abbruch (wie Ur-Archiv).
set -eu

need() { command -v "$1" >/dev/null 2>&1; }

echo "[install-legacy] Checking dependencies (opkg)…"
if ! need opkg; then
  echo "[install-legacy] ERROR: opkg not found. Are you on OpenWrt?"; exit 1
fi

echo "[install-legacy] opkg update…"
opkg update >/dev/null 2>&1 || true

# Ensure base packages
BASE_PKGS="keepalived ip-full uci uhttpd luci-compat luci-base"
for p in $BASE_PKGS; do
  if ! opkg list-installed | awk '{print $1}' | grep -qx "$p"; then
    echo "[install-legacy] Installing $p…"
    opkg install "$p"
  fi
done

# Copy service files (like Ur-Installer tat)
SRC_DIR="$(cd "$(dirname "$0")/.."; pwd)"
echo "[install-legacy] Installing HA files from $SRC_DIR/ha-vrrp/files …"
cp -a "$SRC_DIR/ha-vrrp/files/." /

# Install LuCI app minimal files (controller/view/model)
if [ -d /usr/lib/lua/luci ]; then
  echo "[install-legacy] Installing LuCI app…"
  mkdir -p /usr/lib/lua/luci/controller/ /usr/lib/lua/luci/model/cbi/ha_vrrp /usr/lib/lua/luci/view/ha_vrrp
  cp -a "$SRC_DIR/luci-app-ha-vrrp/luasrc/controller/." /usr/lib/lua/luci/controller/ 2>/dev/null || true
  cp -a "$SRC_DIR/luci-app-ha-vrrp/luasrc/model/cbi/ha_vrrp/." /usr/lib/lua/luci/model/cbi/ha_vrrp/ 2>/dev/null || true
  cp -a "$SRC_DIR/luci-app-ha-vrrp/luasrc/view/ha_vrrp/." /usr/lib/lua/luci/view/ha_vrrp/ 2>/dev/null || true
fi

# Permissions
chmod +x /etc/init.d/ha-vrrp 2>/dev/null || true
chmod +x /etc/init.d/ha-vrrp-syncd 2>/dev/null || true
chmod +x /usr/sbin/ha-vrrp-* 2>/dev/null || true
chmod +x /usr/libexec/ha-vrrp/* 2>/dev/null || true

# Start services
echo "[install-legacy] Enabling and starting services…"
/etc/init.d/ha-vrrp enable || true
/etc/init.d/ha-vrrp restart || true
/etc/init.d/rpcd restart || true
/etc/init.d/uhttpd restart || true

echo "[install-legacy] Done."
