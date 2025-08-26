#!/usr/bin/env python3
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

# genpatch007_reviewfix3b01.py — Pfade auf /root/vrrp-repo umgestellt
import os, zipfile, tarfile, shutil, datetime, textwrap, json, stat, hashlib

BASE_DIR = "/root/vrrp-repo"

inputs = {
    "0.5.16-007_reviewfix3a": os.path.join(BASE_DIR, "openwrt-ha-vrrp-0.5.16-007_reviewfix3a.zip"),
    "0.5.16-008_reviewfix3a": os.path.join(BASE_DIR, "openwrt-ha-vrrp-0.5.16-008_reviewfix3a.zip"),
    "0.5.16-009_reviewfix3a": os.path.join(BASE_DIR, "openwrt-ha-vrrp-0.5.16-009_reviewfix3a.zip"),
}

def ensure_executable(path):
    st = os.stat(path)
    os.chmod(path, st.st_mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)

# ---------------- version.sh (unverändert bis auf Pfade) ----------------
version_sh = """#!/bin/sh
# ------------------------------------------------------------------
# version.sh - Hilfsfunktionen für Versionen (BusyBox/ash-kompatibel)
# ------------------------------------------------------------------

series_from_version() {
  echo "$1" | awk -F- '{print $1}'
}

patch_from_version() {
  case "$1" in
    *-*) echo "$1" | awk -F- '{print $2}' ;;
     *)  echo "" ;;
  esac
}

pad3() {
  n="${1:-0}"
  n=$((10#$n))
  printf "%03d" "$n"
}

latest_patch_for_series() {
  series="$1"
  ls -1 "scripts/installer-v${series}-"*.sh 2>/dev/null | \
    sed -n "s|^scripts/installer-v${series}-\([0-9][0-9][0-9]\)\.sh$|\1|p" | \
    sort -n | tail -n1
}
"""

# ---------------- Wrapper: scripts/installer.sh ----------------
installer_series = """#!/bin/sh
set -eu
HERE="$(cd "$(dirname "$0")" && pwd)"
. "$HERE/lib/version.sh"

SERIES="0.5.16"
PATCH="$(latest_patch_for_series "$SERIES")"
if [ -z "$PATCH" ]; then
  echo "[!] Konnte kein Installer-Skript für Serie $SERIES finden." >&2
  exit 1
fi

echo "[*] Wrapper: delegiere an installer-v${SERIES}-${PATCH}.sh"
exec "$HERE/installer-v${SERIES}-${PATCH}.sh" "$@"
"""

# ---------------- Version-Installer (007 / 008 / 009) ----------------
installer_007 = """#!/bin/sh
# Versions-Installer: 0.5.16-007 (stabile UI)
set -eu

HERE="$(cd "$(dirname "$0")" && pwd)"
PKGROOT="$(cd "$HERE/.." && pwd)"
. "$HERE/lib/version.sh"

TARGET_VERSION="0.5.16-007"
SERIES="$(series_from_version "$TARGET_VERSION")"
PATCH="$(pad3 "$(patch_from_version "$TARGET_VERSION")")"

echo "[*] Installer startet für Version: $TARGET_VERSION"

TS="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="/etc/ha-vrrp"
mkdir -p "$BACKUP_DIR"
BACKUP="${BACKUP_DIR}/backup-${TS}.tgz"
if [ -f /etc/config/ha_vrrp ]; then
  tar -czf "$BACKUP" /etc/config/ha_vrrp 2>/dev/null || true
fi
echo "[*] Config-Backup: $BACKUP"

CUR=""
if [ -f /usr/lib/ha-vrrp/VERSION ]; then
  CUR="$(cat /usr/lib/ha-vrrp/VERSION 2>/dev/null || true)"
fi
echo "[*] Gefundene installierte Version: ${CUR:-<keine>}"

/* migrations werden bewusst vom Series-Installer erledigt */

[ -d "$PKGROOT/luci-app-ha-vrrp" ] && cp -a "$PKGROOT/luci-app-ha-vrrp/." /
[ -d "$PKGROOT/usr" ] && cp -a "$PKGROOT/usr/." /
[ -d "$PKGROOT/etc" ] && cp -a "$PKGROOT/etc/." /

mkdir -p /usr/lib/ha-vrrp
printf "%s\n" "$TARGET_VERSION" > /usr/lib/ha-vrrp/VERSION

uci -q set ha_vrrp.core.cluster_version="$TARGET_VERSION" || true
uci -q commit ha_vrrp || true

rm -f /tmp/luci-* 2>/dev/null || true
/etc/init.d/uhttpd reload 2>/dev/null || /etc/init.d/uhttpd restart 2>/dev/null || true
/etc/init.d/rpcd restart 2>/dev/null || true

echo "[*] Installation abgeschlossen: $TARGET_VERSION"
"""

installer_008 = """#!/bin/sh
# Versions-Installer: 0.5.16-008
set -eu

HERE="$(cd "$(dirname "$0")" && pwd)"
PKGROOT="$(cd "$HERE/.." && pwd)"
. "$HERE/lib/version.sh"

TARGET_VERSION="0.5.16-008"
SERIES="$(series_from_version "$TARGET_VERSION")"
PATCH="$(pad3 "$(patch_from_version "$TARGET_VERSION")")"

echo "[*] Installer startet für Version: $TARGET_VERSION"

TS="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="/etc/ha-vrrp"
mkdir -p "$BACKUP_DIR"
BACKUP="${BACKUP_DIR}/backup-${TS}.tgz"
if [ -f /etc/config/ha_vrrp ]; then
  tar -czf "$BACKUP" /etc/config/ha_vrrp 2>/dev/null || true
fi
echo "[*] Config-Backup: $BACKUP"

CUR=""
if [ -f /usr/lib/ha-vrrp/VERSION ]; then
  CUR="$(cat /usr/lib/ha-vrrp/VERSION 2>/dev/null || true)"
fi
echo "[*] Gefundene installierte Version: ${CUR:-<keine>}"

run_mig() {
  [ -x "$1" ] || { echo "[*] Überspringe Migration (nicht vorhanden): $1"; return 0; }
  echo "[*] Migration: $1"
  "$1" || true
}

case "$CUR" in
  "")
    ;;
  0.5.16-002)
    run_mig "$scripts/migrations/migrate_0.5.16_002_to_007.sh"
    run_mig "$scripts/migrations/migrate_0.5.16_007_to_008.sh"
    ;;
  0.5.16-003|0.5.16-004|0.5.16-005|0.5.16-006)
    run_mig "$scripts/migrations/migrate_0.5.16_002_to_007.sh"
    run_mig "$scripts/migrations/migrate_0.5.16_007_to_008.sh"
    ;;
  0.5.16-007)
    run_mig "$scripts/migrations/migrate_0.5.16_007_to_008.sh"
    ;;
  0.5.16-008)
    echo "[*] System ist bereits auf 0.5.16-008; Re-Install." ;;
  *)
    echo "[!] Unbekannter Startstand: $CUR  → konservative Migration 002→007→008."
    run_mig "$scripts/migrations/migrate_0.5.16_002_to_007.sh" || true
    run_mig "$scripts/migrations/migrate_0.5.16_007_to_008.sh" || true
    ;;
esac

[ -d "$PKGROOT/luci-app-ha-vrrp" ] && cp -a "$PKGROOT/luci-app-ha-vrrp/." /
[ -d "$PKGROOT/usr" ] && cp -a "$PKGROOT/usr/." /
[ -d "$PKGROOT/etc" ] && cp -a "$PKGROOT/etc/." /

mkdir -p /usr/lib/ha-vrrp
printf "%s\n" "$TARGET_VERSION" > /usr/lib/ha-vrrp/VERSION

uci -q set ha_vrrp.core.cluster_version="$TARGET_VERSION" || true
uci -q commit ha_vrrp || true

rm -f /tmp/luci-* 2>/dev/null || true
/etc/init.d/uhttpd reload 2>/dev/null || /etc/init.d/uhttpd restart 2>/dev/null || true
/etc/init.d/rpcd restart 2>/dev/null || true

echo "[*] Installation abgeschlossen: $TARGET_VERSION"
"""

installer_009 = """#!/bin/sh
# Versions-Installer: 0.5.16-009
set -eu

HERE="$(cd "$(dirname "$0")" && pwd)"
PKGROOT="$(cd "$HERE/.." && pwd)"
. "$HERE/lib/version.sh"

TARGET_VERSION="0.5.16-009"
SERIES="$(series_from_version "$TARGET_VERSION")"
PATCH="$(pad3 "$(patch_from_version "$TARGET_VERSION")")"

echo "[*] Installer startet für Version: $TARGET_VERSION"

TS="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="/etc/ha-vrrp"
mkdir -p "$BACKUP_DIR"
BACKUP="${BACKUP_DIR}/backup-${TS}.tgz"
if [ -f /etc/config/ha_vrrp ]; then
  tar -czf "$BACKUP" /etc/config/ha_vrrp 2>/dev/null || true
fi
echo "[*] Config-Backup: $BACKUP"

CUR=""
if [ -f /usr/lib/ha-vrrp/VERSION ]; then
  CUR="$(cat /usr/lib/ha-vrrp/VERSION 2>/dev/null || true)"
fi
echo "[*] Gefundene installierte Version: ${CUR:-<keine>}"

run_mig() {
  [ -x "$1" ] || { echo "[*] Überspringe Migration (nicht vorhanden): $1"; return 0; }
  echo "[*] Migration: $1"
  "$1" || true
}

case "$CUR" in
  "")
    ;;
  0.5.16-002)
    run_mig "$scripts/migrations/migrate_0.5.16_002_to_007.sh"
    run_mig "$scripts/migrations/migrate_0.5.16_007_to_008.sh"
    run_mig "$scripts/migrations/migrate_0.5.16_008_to_009.sh"
    ;;
  0.5.16-003|0.5.16-004|0.5.16-005|0.5.16-006)
    run_mig "$scripts/migrations/migrate_0.5.16_002_to_007.sh"
    run_mig "$scripts/migrations/migrate_0.5.16_007_to_008.sh"
    run_mig "$scripts/migrations/migrate_0.5.16_008_to_009.sh"
    ;;
  0.5.16-007)
    run_mig "$scripts/migrations/migrate_0.5.16_007_to_008.sh"
    run_mig "$scripts/migrations/migrate_0.5.16_008_to_009.sh"
    ;;
  0.5.16-008)
    run_mig "$scripts/migrations/migrate_0.5.16_008_to_009.sh"
    ;;
  0.5.16-009)
    echo "[*] System ist bereits auf 0.5.16-009; Re-Install." ;;
  *)
    echo "[!] Unbekannter Startstand: $CUR  → konservative Migration 002→007→008→009."
    run_mig "$scripts/migrations/migrate_0.5.16_002_to_007.sh" || true
    run_mig "$scripts/migrations/migrate_0.5.16_007_to_008.sh" || true
    run_mig "$scripts/migrations/migrate_0.5.16_008_to_009.sh" || true
    ;;
esac

[ -d "$PKGROOT/luci-app-ha-vrrp" ] && cp -a "$PKGROOT/luci-app-ha-vrrp/." /
[ -d "$PKGROOT/usr" ] && cp -a "$PKGROOT/usr/." /
[ -d "$PKGROOT/etc" ] && cp -a "$PKGROOT/etc/." /

mkdir -p /usr/lib/ha-vrrp
printf "%s\n" "$TARGET_VERSION" > /usr/lib/ha-vrrp/VERSION

uci -q set ha_vrrp.core.cluster_version="$TARGET_VERSION" || true
uci -q commit ha_vrrp || true

rm -f /tmp/luci-* 2>/dev/null || true
/etc/init.d/uhttpd reload 2>/dev/null || /etc/init.d/uhttpd restart 2>/dev/null || true
/etc/init.d/rpcd restart 2>/dev/null || true

echo "[*] Installation abgeschlossen: $TARGET_VERSION"
"""

mig_007_008 = """#!/bin/sh
set -eu
echo "[*] MIGRATE 0.5.16-007 → 0.5.16-008"
uci -q get ha_vrrp.core.peer_netmask_cidr >/dev/null 2>&1 || uci -q set ha_vrrp.core.peer_netmask_cidr="24"
uci -q commit ha_vrrp || true
"""

mig_008_009 = """#!/bin/sh
set -eu
echo "[*] MIGRATE 0.5.16-008 → 0.5.16-009"
uci -q get ha_vrrp.core.cluster_id >/dev/null 2>&1 || uci -q set ha_vrrp.core.cluster_id="default"
uci -q commit ha_vrrp || true
"""

def augment_archive(name, in_zip):
    # Entpacke direkt nach /root/vrrp-repo
    if not os.path.isdir(BASE_DIR):
        os.makedirs(BASE_DIR, exist_ok=True)

    # Bestimme Top-Level-Verzeichnis aus dem ZIP
    with zipfile.ZipFile(in_zip, "r") as z:
        members = [n for n in z.namelist() if not n.startswith("__MACOSX/")]
        top_candidates = {n.split("/")[0] for n in members if "/" in n}
        z.extractall(BASE_DIR)
    top = os.path.join(BASE_DIR, top_candidates.pop()) if len(top_candidates)==1 else BASE_DIR

    # Struktur anlegen und Dateien erzeugen
    scripts_dir = os.path.join(top, "scripts")
    lib_dir = os.path.join(scripts_dir, "lib")
    os.makedirs(lib_dir, exist_ok=True)

    with open(os.path.join(lib_dir, "version.sh"), "w", encoding="utf-8") as f: f.write(version_sh)
    ensure_executable(os.path.join(lib_dir, "version.sh"))
    with open(os.path.join(scripts_dir, "installer.sh"), "w", encoding="utf-8") as f: f.write(installer_series)
    ensure_executable(os.path.join(scripts_dir, "installer.sh"))

    with open(os.path.join(scripts_dir, "installer-v0.5.16-007.sh"), "w", encoding="utf-8") as f: f.write(installer_007)
    ensure_executable(os.path.join(scripts_dir, "installer-v0.5.16-007.sh"))
    with open(os.path.join(scripts_dir, "installer-v0.5.16-008.sh"), "w", encoding="utf-8") as f: f.write(installer_008)
    ensure_executable(os.path.join(scripts_dir, "installer-v0.5.16-008.sh"))
    with open(os.path.join(scripts_dir, "installer-v0.5.16-009.sh"), "w", encoding="utf-8") as f: f.write(installer_009)
    ensure_executable(os.path.join(scripts_dir, "installer-v0.5.16-009.sh"))

    # Migration-Skripte
    mig_dir = os.path.join(top, "usr", "lib", "ha-vrrp", "scripts")
    os.makedirs(mig_dir, exist_ok=True)
    for fn, content in [
        ("scripts/migrations/migrate_0.5.16_007_to_008.sh", mig_007_008),
        ("scripts/migrations/migrate_0.5.16_008_to_009.sh", mig_008_009),
    ]:
        mpath = os.path.join(mig_dir, fn)
        if not os.path.exists(mpath):
            with open(mpath, "w", encoding="utf-8") as f: f.write(content)
        ensure_executable(mpath)

    # VERSION + Archiv-Bezeichner auf reviewfix3b heben
    tag = name.replace("reviewfix3a", "reviewfix3b")
    with open(os.path.join(top, "VERSION"), "w", encoding="utf-8") as f:
        f.write(tag + "\n")

    # Packe TAR und TAR.GZ unter /root/vrrp-repo
    out_base = os.path.join(BASE_DIR, f"openwrt-ha-vrrp-{tag}")
    for ext, mode in [(".tar","w"),(".tar.gz","w:gz")]:
        if os.path.exists(out_base+ext): os.remove(out_base+ext)
        with tarfile.open(out_base+ext, mode) as tf:
            tf.add(top, arcname=os.path.basename(top))

    return {
        "name": name,
        "out_tar": out_base + ".tar",
        "out_targz": out_base + ".tar.gz"
    }

def main():
    results = {}
    for name, path in inputs.items():
        results[name] = augment_archive(name, path)
    print(json.dumps(results, indent=2))

if __name__ == "__main__":
    main()
