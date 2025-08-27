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

# install_v0.5.3.sh – Smart installer for openwrt-ha-vrrp v0.5.3
set -eu

need() { command -v "$1" >/dev/null 2>&1; }

echo "[install] Starting installer for openwrt-ha-vrrp v0.5.3"

if ! need opkg; then
  echo "[install] WARN: opkg not found (not an OpenWrt runtime?). Falling back to overlay copy."
  MODE="overlay"
else
  MODE="opkg"
fi

# Try IPK-based install first
if [ "$MODE" = "opkg" ]; then
  echo "[install] Using opkg. If IPKs are provided, they will be installed."
  set +e
  HAPK="$(ls /tmp/ha-vrrp_0.5.3-1_*.ipk 2>/dev/null | head -n1)"
  LUCIIPK="$(ls /tmp/luci-app-ha-vrrp_0.5.3-1_*.ipk 2>/dev/null | head -n1)"
  set -e
  if [ -n "$HAPK" ] && [ -n "$LUCIIPK" ]; then
    opkg update || true
    opkg install "$HAPK" "$LUCIIPK"
    /etc/init.d/ha-vrrp enable
    /etc/init.d/ha-vrrp restart || true
    /etc/init.d/rpcd restart || true
    /etc/init.d/uhttpd restart || true
    echo "[install] Done (ipk mode)."
    exit 0
  else
    echo "[install] IPKs not found in /tmp, proceeding with overlay copy..."
    MODE="overlay"
  fi
fi

# Overlay copy mode – copy files from this tree into rootfs
SRC_DIR="$(cd "$(dirname "$0")/.."; pwd)"
echo "[install] Copying files from $SRC_DIR to /"
cp -a "$SRC_DIR/ha-vrrp/files/." /
cp -a "$SRC_DIR/luci-app-ha-vrrp/." /tmp/_luci-ha-vrrp-src 2>/dev/null || true
# try to detect LuCI tree (on live systems, we only need configs and controllers)
if [ -d /usr/lib/lua/luci ]; then
  mkdir -p /usr/lib/lua/luci/controller/ /usr/lib/lua/luci/model/cbi/ /usr/lib/lua/luci/view/
  # Copy minimal app files
  if [ -d "$SRC_DIR/luci-app-ha-vrrp/luasrc" ]; then
    cp -a "$SRC_DIR/luci-app-ha-vrrp/luasrc/controller/." /usr/lib/lua/luci/controller/ 2>/dev/null || true
    mkdir -p /usr/lib/lua/luci/model/cbi/ha_vrrp /usr/lib/lua/luci/view/ha_vrrp
    cp -a "$SRC_DIR/luci-app-ha-vrrp/luasrc/model/cbi/ha_vrrp/." /usr/lib/lua/luci/model/cbi/ha_vrrp/ 2>/dev/null || true
    cp -a "$SRC_DIR/luci-app-ha-vrrp/luasrc/view/ha_vrrp/." /usr/lib/lua/luci/view/ha_vrrp/ 2>/dev/null || true
  fi
fi

# Ensure permissions
chmod +x /etc/init.d/ha-vrrp || true
chmod +x /etc/init.d/ha-vrrp-syncd || true
chmod +x /usr/sbin/ha-vrrp-* || true
chmod +x /usr/libexec/ha-vrrp/* || true

# Start services
/etc/init.d/ha-vrrp enable || true
/etc/init.d/ha-vrrp restart || true
/etc/init.d/rpcd restart || true
/etc/init.d/uhttpd restart || true

echo "[install] Done (overlay mode)."
