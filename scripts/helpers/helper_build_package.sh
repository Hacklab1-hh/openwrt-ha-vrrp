#!/bin/sh
# Build a release package for the HA VRRP add‑on.
#
# This helper synchronises version tags and documentation, runs smoke tests
# and assembles a tar and gzipped tarball in the `dist` directory.  It
# assumes it is executed from within the `scripts/helpers` directory.

set -eu
root="$(cd "$(dirname "$0")/../.." && pwd)"
dist="$root/dist"

mkdir -p "$dist"

# Run helpers
sh "$root/scripts/helpers/helper_update_version_tags.sh"
sh "$root/scripts/helpers/helper_sync_docs.sh"
sh "$root/scripts/helpers/helper_smoketests.sh"

VERSION="$(tr -d '\r\n' < "$root/VERSION")"
pkgname="openwrt-ha-vrrp-$VERSION"

# Create package tar (exclude dist directory itself)
# Exclude old `docs/changelog` directory to avoid duplicate or outdated changelog files.
tar -C "$root" -cf "$dist/$pkgname.tar" \
    --exclude='./dist' \
    --exclude='./.git' \
    --exclude='./docs/changelog' \
    .
gzip -f "$dist/$pkgname.tar"

echo "[helper_build_package] Built $dist/$pkgname.tar.gz"