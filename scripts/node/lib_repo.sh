#!/bin/sh
set -eu
is_cmd(){ command -v "$1" >/dev/null 2>&1; }
repo_is_archive(){ case "$1" in *.tar.gz|*.tgz|*.tar|*.zip) return 0;; *) return 1;; esac; }
repo_find_latest_archive(){ dir="$1"; find "$dir" -maxdepth 1 -type f \
  \( -name '*.tar.gz' -o -name '*.tgz' -o -name '*.tar' -o -name '*.zip' \) \
  -printf '%T@ %p\n' 2>/dev/null | sort -n | tail -n1 | awk '{sub($1 FS,"");print $0}'; }
repo_guess_version_from_filename(){ bn="$1"; case "$bn" in openwrt-ha-vrrp-*) echo "${bn#openwrt-ha-vrrp-}" | sed -E 's/\.(tar\.gz|tgz|tar|zip)$//';; *) echo "$(echo "$bn" | sed -E 's/\.(tar\.gz|tgz|tar|zip)$//')";; esac; }
repo_toplevel_from_archive(){ arc="$1"; case "$arc" in *.zip) unzip -l "$arc" 2>/dev/null | awk 'NR>3 && $4!~/\/$/ {print $4}' | awk -F/ 'NF{print $1;exit}';; *.tar.gz|*.tgz) tar -tzf "$arc" 2>/dev/null | awk -F/ 'NF{print $1;exit}';; *.tar) tar -tf "$arc" 2>/dev/null | awk -F/ 'NF{print $1;exit}';; *) echo "";; esac; }
repo_extract_archive_to_cache(){ arc="$1"; cache="$2"; version="$3"; [ -f "$arc" ] || { echo "Archive not found: $arc" >&2; return 1; }
  mkdir -p "$cache"; dest="$cache/$version"; [ -d "$dest" ] && { echo "[INFO] Cache vorhanden: $dest"; return 0; }
  tmp="$dest.__tmp"; rm -rf "$tmp"; mkdir -p "$tmp"; echo "[INFO] Entpacke $arc ..."
  case "$arc" in *.zip) unzip -q "$arc" -d "$tmp";; *.tar.gz|*.tgz) tar -xzf "$arc" -C "$tmp";; *.tar) tar -xf "$arc" -C "$tmp";; *) echo "Unsupported: $arc" >&2; rm -rf "$tmp"; return 2;; esac
  TL="$(repo_toplevel_from_archive "$arc")"; if [ -n "$TL" ] && [ -d "$tmp/$TL" ]; then mv "$tmp/$TL" "$dest"; rm -rf "$tmp"; else mv "$tmp" "$dest"; fi; echo "[OK] Cache: $dest"; }
repo_extract_version_from_local(){ repo="$1"; cache="$2"; version="$3"; [ -n "$version" ] || return 1
  f="$(ls -1 "$repo"/openwrt-ha-vrrp-"$version".* 2>/dev/null | head -n1 || true)"
  [ -z "$f" ] && f="$(ls -1 "$repo"/*"$version"* 2>/dev/null | head -n1 || true)"
  [ -n "$f" ] || { echo "Kein Archiv für Version $version in $repo" >&2; return 2; }
  repo_extract_archive_to_cache "$f" "$cache" "$version"; }
repo_switch_symlink(){ cache="$1"; link="$2"; version="$3"; target="$cache/$version"; [ -d "$target" ] || { echo "Cache-Ziel fehlt: $target" >&2; return 2; }
  if [ -L "$link" ] || [ -e "$link" ]; then rm -f "$link"; fi; ln -s "$target" "$link"; echo "[OK] Aktiv: $link -> $target"; }
repo_git_prepare_snapshot(){ gitdir="$1"; cache="$2"; req_version="${3:-}"; if ! is_cmd git; then echo "[WARN] git fehlt"; return 1; fi
  [ -d "$gitdir/.git" ] || { echo "[INFO] kein git clone in $gitdir"; return 2; }
  ( cd "$gitdir" && git fetch --all --prune && git pull --ff-only ) || true
  ver="$req_version"; if [ -z "$ver" ]; then ver="$(cd "$gitdir" && (git describe --tags --abbrev=0 2>/dev/null || git rev-parse --short=12 HEAD))"; else
    ( cd "$gitdir" && git rev-parse --verify "$ver^{object}" >/dev/null 2>&1 ) || ver="$(cd "$gitdir" && git rev-parse --short=12 HEAD)"; fi
  snap="$cache/$ver"; [ -d "$snap" ] && { echo "[INFO] Snapshot vorhanden: $snap"; return 0; }
  mkdir -p "$snap"; ( cd "$gitdir" && git archive --format=tar "$ver" ) | tar -x -C "$snap"; echo "[OK] Git-Snapshot: $snap"; }
repo_last_git_version_name(){ gitdir="$1"; command -v git >/dev/null 2>&1 && [ -d "$gitdir/.git" ] || return 1
  ( cd "$gitdir" && git describe --tags --always --dirty 2>/dev/null || git rev-parse --short=12 HEAD ); }
