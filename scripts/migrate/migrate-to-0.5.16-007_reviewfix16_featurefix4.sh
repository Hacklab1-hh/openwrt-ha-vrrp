#!/bin/sh
set -eu
base="$(cd "$(dirname "$0")/../.." && pwd)"
echo "[migrate] applying migration to 0.5.16-007_reviewfix16_featurefix4"

# Move old workflow prompt if present (idempotent)
if [ -f "$base/docs/PROMPT-WORKFLOW.md" ]; then
  mkdir -p "$base/docs/release-workflow-prompt"
  mv -f "$base/docs/PROMPT-WORKFLOW.md" "$base/docs/release-workflow-prompt/development-change-PROMPT-WORKFLOW.md"
  echo "[migrate] moved docs/PROMPT-WORKFLOW.md -> docs/release-workflow-prompt/development-change-PROMPT-WORKFLOW.md"
fi

# Ensure docs/README.md references new path
if [ -f "$base/docs/README.md" ]; then
  ref="docs/release-workflow-prompt/development-change-PROMPT-WORKFLOW.md"
  grep -q "$ref" "$base/docs/README.md" || printf "\n## Release/Workflow\n- Workflow-Prompt: `%s`\n" "$ref" >> "$base/docs/README.md"
fi

echo "[migrate] done"
