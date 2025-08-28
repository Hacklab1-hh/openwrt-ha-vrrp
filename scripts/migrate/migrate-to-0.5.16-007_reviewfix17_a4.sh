#!/bin/sh
# Migration script for version 0.5.16‑007_reviewfix17_a4
#
# This release introduces a preset‑based configuration system and does not
# require any runtime migration of user data or configuration files.
#
# The version bump is documented in `docs/changelogs/0.5.16-007_reviewfix17_a4.md`.
# No changes to UCI or file layout are necessary.

set -eu

echo "[migrate] Nothing to migrate for 0.5.16-007_reviewfix17_a4" >&2
exit 0