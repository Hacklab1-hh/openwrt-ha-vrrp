import os, zipfile, tarfile, shutil, datetime, textwrap, json, stat, hashlib

inputs = {
    "0.5.16-007_reviewfix3a": "/mnt/data/openwrt-ha-vrrp-0.5.16-007_reviewfix3a.zip",
    "0.5.16-008_reviewfix3a": "/mnt/data/openwrt-ha-vrrp-0.5.16-008_reviewfix3a.zip",
    "0.5.16-009_reviewfix3a": "/mnt/data/openwrt-ha-vrrp-0.5.16-009_reviewfix3a.zip",
}

version_sh = """#!/bin/sh
series_from_version() { echo "$1" | awk -F- '{print $1}'; }
patch_from_version() { case "$1" in *-*) echo "$1" | awk -F- '{print $2}' ;; *) echo "" ;; esac; }
pad3() { n="${1:-0}"; n=$((10#$n)); printf "%03d" "$n"; }
latest_patch_for_series() {
  series="$1"
  ls -1 "scripts/installer-v${series}-"*.sh 2>/dev/null | \
    sed -n "s|^scripts/installer-v${series}-\\([0-9][0-9][0-9]\\)\\.sh$|\\1|p" | \
    sort -n | tail -n1
}
"""

installer_wrapper_series = """#!/bin/sh
set -eu
HERE="$(cd "$(dirname "$0")" && pwd)"
exec "$HERE/installer-v0.5.16.sh" "$@"
"""

installer_series = """#!/bin/sh
set -eu
HERE="$(cd "$(dirname "$0")" && pwd)"
. "$HERE/lib/version.sh"
SERIES="0.5.16"
PATCH="$(latest_patch_for_series "$SERIES")"
if [ -z "${PATCH:-}" ]; then
  echo "[!] Kein versionsspezifischer Installer gefunden: scripts/installer-v${SERIES}-*.sh" >&2
  exit 1
fi
echo "[*] Wrapper: delegiere an installer-v${SERIES}-${PATCH}.sh"
exec "$HERE/installer-v${SERIES}-${PATCH}.sh" "$@"
"""

installer_007 = """#!/bin/sh
set -eu
HERE="$(cd "$(dirname "$0")" && pwd)"
PKGROOT="$(cd "$HERE/.." && pwd)"
. "$HERE/lib/version.sh"
TARGET_VERSION="0.5.16-007"
SERIES="$(series_from_version "$TARGET_VERSION")"
PATCH="$(pad3 "$(patch_from_version "$TARGET_VERSION")")"
echo "[*] Installer startet für Version: $TARGET_VERSION"
TS="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="/etc/ha-vrrp"; mkdir -p "$BACKUP_DIR"
BACKUP="${BACKUP_DIR}/backup-${TS}.tgz"
[ -f /etc/config/ha_vrrp ] && tar -czf "$BACKUP" /etc/config/ha_vrrp 2>/dev/null || true
echo "[*] Config-Backup: $BACKUP"
CUR=""; [ -f /usr/lib/ha-vrrp/VERSION ] && CUR="$(cat /usr/lib/ha-vrrp/VERSION 2>/dev/null || true)"
case "$CUR" in
  0.5.16-002)
    [ -x "$PKGROOT/usr/lib/ha-vrrp/scripts/migrations/migrate_0.5.16_002_to_007.sh" ] && \
      "$PKGROOT/usr/lib/ha-vrrp/scripts/migrations/migrate_0.5.16_002_to_007.sh" || true
  ;;
esac
[ -d "$PKGROOT/luci-app-ha-vrrp" ] && cp -a "$PKGROOT/luci-app-ha-vrrp/." /
[ -d "$PKGROOT/usr" ] && cp -a "$PKGROOT/usr/." /
[ -d "$PKGROOT/etc" ] && cp -a "$PKGROOT/etc/." /
mkdir -p /usr/lib/ha-vrrp; printf "%s\\n" "$TARGET_VERSION" > /usr/lib/ha-vrrp/VERSION
uci -q set ha_vrrp.core.cluster_version="$TARGET_VERSION" || true
uci -q commit ha_vrrp || true
rm -f /tmp/luci-* 2>/dev/null || true
/etc/init.d/uhttpd reload 2>/dev/null || /etc/init.d/uhttpd restart 2>/dev/null || true
/etc/init.d/rpcd restart 2>/dev/null || true
echo "[*] Installation abgeschlossen: $TARGET_VERSION"
"""

installer_008 = """#!/bin/sh
set -eu
HERE="$(cd "$(dirname "$0")" && pwd)"
PKGROOT="$(cd "$HERE/.." && pwd)"
. "$HERE/lib/version.sh"
TARGET_VERSION="0.5.16-008"
SERIES="$(series_from_version "$TARGET_VERSION")"
PATCH="$(pad3 "$(patch_from_version "$TARGET_VERSION")")"
echo "[*] Installer startet für Version: $TARGET_VERSION"
TS="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="/etc/ha-vrrp"; mkdir -p "$BACKUP_DIR"
BACKUP="${BACKUP_DIR}/backup-${TS}.tgz"
[ -f /etc/config/ha_vrrp ] && tar -czf "$BACKUP" /etc/config/ha_vrrp 2>/dev/null || true
echo "[*] Config-Backup: $BACKUP"
CUR=""; [ -f /usr/lib/ha-vrrp/VERSION ] && CUR="$(cat /usr/lib/ha-vrrp/VERSION 2>/dev/null || true)"
echo "[*] Gefundene installierte Version: ${CUR:-<keine>}"
run_mig() { [ -x "$1" ] || { echo "[*] Überspringe Migration (nicht vorhanden): $1"; return 0; }; echo "[*] Migration: $1"; "$1" || true; }
case "$CUR" in
  "")
    ;;
  0.5.16-002)
    run_mig "$PKGROOT/usr/lib/ha-vrrp/scripts/migrations/migrate_0.5.16_002_to_007.sh"
    run_mig "$PKGROOT/usr/lib/ha-vrrp/scripts/migrations/migrate_0.5.16_007_to_008.sh"
    ;;
  0.5.16-003|0.5.16-004|0.5.16-005|0.5.16-006)
    run_mig "$PKGROOT/usr/lib/ha-vrrp/scripts/migrations/migrate_0.5.16_002_to_007.sh"
    run_mig "$PKGROOT/usr/lib/ha-vrrp/scripts/migrations/migrate_0.5.16_007_to_008.sh"
    ;;
  0.5.16-007)
    run_mig "$PKGROOT/usr/lib/ha-vrrp/scripts/migrations/migrate_0.5.16_007_to_008.sh"
    ;;
  0.5.16-008)
    echo "[*] System ist bereits auf 0.5.16-008; Re-Install." ;;
  *)
    echo "[!] Unbekannter Startstand: $CUR  → konservative Migration 002→007→008."
    run_mig "$PKGROOT/usr/lib/ha-vrrp/scripts/migrations/migrate_0.5.16_002_to_007.sh" || true
    run_mig "$PKGROOT/usr/lib/ha-vrrp/scripts/migrations/migrate_0.5.16_007_to_008.sh" || true
    ;;
esac
[ -d "$PKGROOT/luci-app-ha-vrrp" ] && cp -a "$PKGROOT/luci-app-ha-vrrp/." /
[ -d "$PKGROOT/usr" ] && cp -a "$PKGROOT/usr/." /
[ -d "$PKGROOT/etc" ] && cp -a "$PKGROOT/etc/." /
mkdir -p /usr/lib/ha-vrrp; printf "%s\\n" "$TARGET_VERSION" > /usr/lib/ha-vrrp/VERSION
uci -q set ha_vrrp.core.cluster_version="$TARGET_VERSION" || true
uci -q commit ha_vrrp || true
rm -f /tmp/luci-* 2>/dev/null || true
/etc/init.d/uhttpd reload 2>/dev/null || /etc/init.d/uhttpd restart 2>/dev/null || true
/etc/init.d/rpcd restart 2>/dev/null || true
echo "[*] Installation abgeschlossen: $TARGET_VERSION"
"""

installer_009 = """#!/bin/sh
set -eu
HERE="$(cd "$(dirname "$0")" && pwd)"
PKGROOT="$(cd "$HERE/.." && pwd)"
. "$HERE/lib/version.sh"
TARGET_VERSION="0.5.16-009"
SERIES="$(series_from_version "$TARGET_VERSION")"
PATCH="$(pad3 "$(patch_from_version "$TARGET_VERSION")")"
echo "[*] Installer startet für Version: $TARGET_VERSION"
TS="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="/etc/ha-vrrp"; mkdir -p "$BACKUP_DIR"
BACKUP="${BACKUP_DIR}/backup-${TS}.tgz"
[ -f /etc/config/ha_vrrp ] && tar -czf "$BACKUP" /etc/config/ha_vrrp 2>/dev/null || true
echo "[*] Config-Backup: $BACKUP"
CUR=""; [ -f /usr/lib/ha-vrrp/VERSION ] && CUR="$(cat /usr/lib/ha-vrrp/VERSION 2>/dev/null || true)"
echo "[*] Gefundene installierte Version: ${CUR:-<keine>}"
run_mig() { [ -x "$1" ] || { echo "[*] Überspringe Migration (nicht vorhanden): $1"; return 0; }; echo "[*] Migration: $1"; "$1" || true; }
case "$CUR" in
  "")
    ;;
  0.5.16-002)
    run_mig "$PKGROOT/usr/lib/ha-vrrp/scripts/migrations/migrate_0.5.16_002_to_007.sh"
    run_mig "$PKGROOT/usr/lib/ha-vrrp/scripts/migrations/migrate_0.5.16_007_to_008.sh"
    run_mig "$PKGROOT/usr/lib/ha-vrrp/scripts/migrations/migrate_0.5.16_008_to_009.sh"
    ;;
  0.5.16-003|0.5.16-004|0.5.16-005|0.5.16-006)
    run_mig "$PKGROOT/usr/lib/ha-vrrp/scripts/migrations/migrate_0.5.16_002_to_007.sh"
    run_mig "$PKGROOT/usr/lib/ha-vrrp/scripts/migrations/migrate_0.5.16_007_to_008.sh"
    run_mig "$PKGROOT/usr/lib/ha-vrrp/scripts/migrations/migrate_0.5.16_008_to_009.sh"
    ;;
  0.5.16-007)
    run_mig "$PKGROOT/usr/lib/ha-vrrp/scripts/migrations/migrate_0.5.16_007_to_008.sh"
    run_mig "$PKGROOT/usr/lib/ha-vrrp/scripts/migrations/migrate_0.5.16_008_to_009.sh"
    ;;
  0.5.16-008)
    run_mig "$PKGROOT/usr/lib/ha-vrrp/scripts/migrations/migrate_0.5.16_008_to_009.sh"
    ;;
  0.5.16-009)
    echo "[*] System ist bereits auf 0.5.16-009; Re-Install." ;;
  *)
    echo "[!] Unbekannter Startstand: $CUR  → konservative Migration 002→007→008→009."
    run_mig "$PKGROOT/usr/lib/ha-vrrp/scripts/migrations/migrate_0.5.16_002_to_007.sh" || true
    run_mig "$PKGROOT/usr/lib/ha-vrrp/scripts/migrations/migrate_0.5.16_007_to_008.sh" || true
    run_mig "$PKGROOT/usr/lib/ha-vrrp/scripts/migrations/migrate_0.5.16_008_to_009.sh" || true
    ;;
esac
[ -d "$PKGROOT/luci-app-ha-vrrp" ] && cp -a "$PKGROOT/luci-app-ha-vrrp/." /
[ -d "$PKGROOT/usr" ] && cp -a "$PKGROOT/usr/." /
[ -d "$PKGROOT/etc" ] && cp -a "$PKGROOT/etc/." /
mkdir -p /usr/lib/ha-vrrp; printf "%s\\n" "$TARGET_VERSION" > /usr/lib/ha-vrrp/VERSION
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
uci -q get ha_vrrp.core.peer_netmask_cidr >/dev/null 2>&1 || uci -q set ha_vrrp.core.peer_netmask_cidr='24'
SSH_BACKEND="$(uci -q get ha_vrrp.core.ssh_backend 2>/dev/null || echo '')"
[ -z "$SSH_BACKEND" ] && uci -q set ha_vrrp.core.ssh_backend='auto'
[ -z "$(uci -q get ha_vrrp.core.sync_method 2>/dev/null || echo '')" ] && uci -q set ha_vrrp.core.sync_method='auto'
[ -z "$(uci -q get ha_vrrp.core.key_type 2>/dev/null || echo '')" ] && uci -q set ha_vrrp.core.key_type='auto'
uci -q commit ha_vrrp || true
echo "[*] MIGRATE done (007→008)"
"""

mig_008_009 = """#!/bin/sh
set -eu
echo "[*] MIGRATE 0.5.16-008 → 0.5.16-009"
uci -q get ha_vrrp.core.cluster_name >/dev/null 2>&1 || uci -q set ha_vrrp.core.cluster_name='lab-ha'
uci -q get ha_vrrp.core.priority >/dev/null 2>&1 || uci -q set ha_vrrp.core.priority='150'
uci -q commit ha_vrrp || true
echo "[*] MIGRATE done (008→009)"
"""

import stat, glob

def ensure_exec(path):
    st = os.stat(path)
    os.chmod(path, st.st_mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)

def augment(in_zip):
    work = in_zip.replace(".zip","_work")
    if os.path.isdir(work): shutil.rmtree(work)
    os.makedirs(work, exist_ok=True)
    with zipfile.ZipFile(in_zip, "r") as z:
        z.extractall(work)
    # detect top
    candidates = [d for d in os.listdir(work) if os.path.isdir(os.path.join(work,d))]
    top = os.path.join(work, candidates[0]) if len(candidates)==1 else work

    scripts = os.path.join(top, "scripts")
    lib = os.path.join(scripts, "lib"); os.makedirs(lib, exist_ok=True)

    open(os.path.join(lib,"version.sh"),"w").write(version_sh); ensure_exec(os.path.join(lib,"version.sh"))
    open(os.path.join(scripts,"installer.sh"),"w").write(installer_wrapper_series); ensure_exec(os.path.join(scripts,"installer.sh"))
    open(os.path.join(scripts,"installer-v0.5.16.sh"),"w").write(installer_series); ensure_exec(os.path.join(scripts,"installer-v0.5.16.sh"))
    open(os.path.join(scripts,"installer-v0.5.16-007.sh"),"w").write(installer_007); ensure_exec(os.path.join(scripts,"installer-v0.5.16-007.sh"))
    open(os.path.join(scripts,"installer-v0.5.16-008.sh"),"w").write(installer_008); ensure_exec(os.path.join(scripts,"installer-v0.5.16-008.sh"))
    open(os.path.join(scripts,"installer-v0.5.16-009.sh"),"w").write(installer_009); ensure_exec(os.path.join(scripts,"installer-v0.5.16-009.sh"))

    mig_dir = os.path.join(top,"usr","lib","ha-vrrp","scripts")
    os.makedirs(mig_dir, exist_ok=True)
    p1 = os.path.join(mig_dir,"migrate_0.5.16_007_to_008.sh")
    p2 = os.path.join(mig_dir,"migrate_0.5.16_008_to_009.sh")
    if not os.path.exists(p1): open(p1,"w").write(mig_007_008)
    if not os.path.exists(p2): open(p2,"w").write(mig_008_009)
    ensure_exec(p1); ensure_exec(p2)

    # bump VERSION file to reviewfix4
    base = os.path.basename(in_zip).replace(".zip","").replace("openwrt-ha-vrrp-","")
    rf4 = base.replace("reviewfix3a","reviewfix4")
    with open(os.path.join(top,"VERSION"),"w") as f: f.write(rf4+"\n")

    out_tar = f"/mnt/data/openwrt-ha-vrrp-{rf4}.tar"
    out_tgz = f"/mnt/data/openwrt-ha-vrrp-{rf4}.tar.gz"
    if os.path.exists(out_tar): os.remove(out_tar)
    if os.path.exists(out_tgz): os.remove(out_tgz)
    with tarfile.open(out_tar,"w") as tf:
        tf.add(top, arcname=os.path.basename(top))
    with tarfile.open(out_tgz,"w:gz") as tf:
        tf.add(top, arcname=os.path.basename(top))
    return out_tar, out_tgz

outputs = {}
for name, p in inputs.items():
    outputs[name] = augment(p)

outputs
