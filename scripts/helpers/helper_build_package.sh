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

# Generate aggregated documentation (CHANGELOG, FEATURES, ARCHITECTURE, CONCEPTS, README, KNOWN_ISSUES)
sh "$root/scripts/gen-base-md.sh"

VERSION="$(tr -d '\r\n' < "$root/VERSION")"
pkgname="openwrt-ha-vrrp-$VERSION"

# Create package tar (exclude dist directory itself and legacy documentation folders/files).
tar -C "$root" -cf "$dist/$pkgname.tar" \
    --exclude='./dist' \
    --exclude='./.git' \
    --exclude='./docs/changelog' \
    --exclude='./docs/Readme' \
    --exclude='./docs/known_issues' \
    --exclude='./docs/features/FEATURES_*' \
    --exclude='./docs/known_issues/KNOWN_ISSUES_*' \
    --exclude='./docs/Readme/README_*' \
    .
gzip -f "$dist/$pkgname.tar"

echo "[helper_build_package] Built $dist/$pkgname.tar.gz"