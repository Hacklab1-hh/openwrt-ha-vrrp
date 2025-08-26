sh "$(dirname "$0")/migratefrom0.5.14to0.5.15.sh" || true
#!/bin/sh
# install_v0.5.15.sh – Installer mit zentraler Dependency-Config (config/dependencies.conf)
set -eu

PKG_VER="0.5.15"
echo "[install] Starting installer for openwrt-ha-vrrp v$PKG_VER"

SELF="$(readlink -f "$0" 2>/dev/null || realpath "$0" 2>/dev/null || echo "$0")"
SCRIPTDIR="$(cd "$(dirname "$SELF")" && pwd)"
REPO_ROOT="$(cd "$SCRIPTDIR/.." && pwd)"
CONF="$REPO_ROOT/config/dependencies.conf"

echo "[install] Repo root: $REPO_ROOT"
echo "[install] Dependency config: $CONF"

# OS detection (simple): allow override via $OS_KEY, else try /etc/openwrt_release
OS_KEY="${OS_KEY:-}"
if [ -z "$OS_KEY" ] && [ -f /etc/openwrt_release ]; then
  # e.g. DISTRIB_RELEASE='19.07.10'
  REL="$(. /etc/openwrt_release; echo ${DISTRIB_RELEASE:-unknown})"
  case "$REL" in
    19.07*) OS_KEY="openwrt-19.07" ;;
    21.02*) OS_KEY="openwrt-21.02" ;;
    22.03*) OS_KEY="openwrt-22.03" ;;
    23.05*) OS_KEY="openwrt-23.05" ;;
    *) OS_KEY="default" ;;
  esac
fi
[ -n "$OS_KEY" ] || OS_KEY="default"
echo "[install] OS key: $OS_KEY"

read_conf_val() {
  # usage: read_conf_val <section> <key>
  awk -v sec="[$1]" -v key="$2" '
    BEGIN{IGNORECASE=1; in=0}
    /^\s*\[.*\]\s*$/ {in=($0==sec)?1:0}
    in && $1 ~ key { sub(/^[^=]*=\s*/,""); print; exit }
    END{}' "$CONF" 2>/dev/null | sed 's/#.*$//' | tr -s " \t" " " | sed 's/^ *//;s/ *$//'
}

RUNTIME_DEF="$(read_conf_val default runtime)"
RUNTIME_OS="$(read_conf_val "$OS_KEY" runtime || true)"
RUNTIME_PKGS="$RUNTIME_DEF"
[ -n "${RUNTIME_OS:-}" ] && RUNTIME_PKGS="$RUNTIME_OS"

echo "[install] Runtime deps: $RUNTIME_PKGS"

# Try IPKs first
IPK_DIRS="$REPO_ROOT/../ipk_0_5_14 $REPO_ROOT/ipk_0_5_14 /tmp $REPO_ROOT"
HA_IPK="ha-vrrp_${PKG_VER}-1_all.ipk"
LUCI_IPK="luci-app-ha-vrrp_${PKG_VER}-1_all.ipk"

install_ipks() {
  for d in $IPK_DIRS; do
    if [ -f "$d/$HA_IPK" ] && [ -f "$d/$LUCI_IPK" ]; then
      echo "[install] Installing IPKs from $d"
      opkg update || true
      opkg install "$d/$HA_IPK" "$d/$LUCI_IPK"
      return 0
    fi
  done
  return 1
}

install_deps() {
  if command -v opkg >/dev/null 2>&1; then
    echo "[deps] Installing runtime deps via opkg: $RUNTIME_PKGS"
    opkg update || true
    for p in $RUNTIME_PKGS; do
      if ! opkg list-installed | grep -qE "^$p "; then
        opkg install "$p" || echo "[deps] WARN: could not install $p"
      fi
    done
  else
    echo "[deps] WARN: opkg not found; cannot install dependencies"
  fi
}

overlay_copy() {
  echo "[install] IPKs not found, proceeding with overlay copy..."
  if [ -d "$REPO_ROOT/ha-vrrp/files" ]; then
    (cd "$REPO_ROOT/ha-vrrp/files" && tar cf - .) | (cd / && tar xvf -)
  else
    echo "[install] WARN: $REPO_ROOT/ha-vrrp/files not found"
  fi
  if [ -d "$REPO_ROOT/luci-app-ha-vrrp/luasrc" ]; then
    mkdir -p /usr/lib/lua/luci
    (cd "$REPO_ROOT/luci-app-ha-vrrp/luasrc" && tar cf - .) | (cd /usr/lib/lua/luci && tar xvf -)
  else
    echo "[install] WARN: $REPO_ROOT/luci-app-ha-vrrp/luasrc not found"
  fi
}

post_install() {
  [ -x /etc/init.d/ha-vrrp ] && /etc/init.d/ha-vrrp enable >/dev/null 2>&1 || true
  [ -x /etc/init.d/ha-vrrp ] && /etc/init.d/ha-vrrp restart >/dev/null 2>&1 || true
  [ -x /etc/init.d/ha-vrrp-syncd ] && /etc/init.d/ha-vrrp-syncd enable >/dev/null 2>&1 || true
  [ -x /etc/init.d/ha-vrrp-syncd ] && /etc/init.d/ha-vrrp-syncd restart >/dev/null 2>&1 || true
  [ -x /etc/init.d/rpcd ] && /etc/init.d/rpcd restart >/dev/null 2>&1 || true
  [ -x /etc/init.d/uhttpd ] && /etc/init.d/uhttpd restart >/dev/null 2>&1 || true

  if command -v ha-vrrp-apply >/dev/null 2>&1; then
    ha-vrrp-apply || true
    [ -x /etc/init.d/keepalived ] && /etc/init.d/keepalived restart >/dev/null 2>&1 || true
  fi

  echo "[install] Hint: clear LuCI cache if menus missing:"
  echo "  rm -f /tmp/luci-indexcache /tmp/luci-modulecache/* 2>/dev/null || true; /etc/init.d/uhttpd restart"
}

install_deps || true

if install_ipks; then
  echo "[install] IPK installation done."
else
  overlay_copy
fi

# final sanity
if [ ! -f /etc/config/ha_vrrp ]; then
  echo "[install] WARN: /etc/config/ha_vrrp missing after install"
fi

# report
if command -v uci >/dev/null 2>&1; then
  INST_CNT="$(uci show ha_vrrp 2>/dev/null | grep -cE '^ha_vrrp\.[^.]+=instance' || true)"
  echo "[ha-vrrp] instances found: ${INST_CNT:-0}"
fi

post_install
echo "[install] Done."
