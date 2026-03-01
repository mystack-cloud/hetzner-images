#!/usr/bin/env bash
# Run the prepare job logic locally. Writes the same outputs to a file so you can
# verify matrix/names and simulate fromJson() without running the full workflow.
# Usage: ./test/scripts/test-prepare.sh [output-file]
#   Default output: .github-output (repo root). Pass - to print only to stdout.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
OUTPUT_FILE="${1:-$REPO_ROOT/.github-output}"

cd "$REPO_ROOT"

if [ ! -f config/images.yaml ]; then
  echo "ERROR: config/images.yaml not found" >&2
  exit 1
fi

if ! command -v yq &>/dev/null; then
  echo "ERROR: yq not installed. Install from https://github.com/mikefarah/yq" >&2
  exit 1
fi

# Same logic as .github/workflows/sync-base-images.yml prepare job
json=$(bash scripts/list.sh --json | tr -d '\n')
if [ -z "$json" ] || [ "$json" = "[]" ]; then
  echo "ERROR: list.sh produced no image/arch pairs (check config/images.yaml)" >&2
  exit 1
fi

echo "Matrix JSON length: ${#json} chars"

# Build GITHUB_OUTPUT-style file (same as in workflow)
if [ "$OUTPUT_FILE" = "-" ]; then
  TARGET="/dev/stdout"
else
  TARGET="$OUTPUT_FILE"
  : > "$TARGET"
fi

printf 'matrix=%s\n' "${json//%/%25}" >> "$TARGET"
images=$(yq -r '.images | keys | .[]' config/images.yaml | sort -u)
echo "names<<NAMES_EOF" >> "$TARGET"
echo "$images" >> "$TARGET"
echo "NAMES_EOF" >> "$TARGET"

if [ "$OUTPUT_FILE" != "-" ]; then
  echo "Wrote outputs to $OUTPUT_FILE"
fi

# Validate: simulate fromJson() on matrix (requires jq)
if command -v jq &>/dev/null; then
  if echo "$json" | jq -e . >/dev/null 2>&1; then
    count=$(echo "$json" | jq 'length')
    echo "Valid JSON matrix: $count entries (fromJson would succeed)"
    echo "First 3 entries:"
    echo "$json" | jq -c '.[:3][]'
  else
    echo "WARNING: matrix value is not valid JSON (fromJson would fail)" >&2
    echo "Raw (first 120 chars): ${json:0:120}..." >&2
  fi
else
  echo "Tip: install jq to validate that the matrix is valid JSON for fromJson()"
fi
