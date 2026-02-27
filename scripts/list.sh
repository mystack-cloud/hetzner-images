#!/usr/bin/env bash
# Reads config/images.yaml and outputs image/arch pairs.
# Usage: list.sh [config] [--json]
#   Default: one line per "image arch". With --json: JSON array for GHA matrix.

set -euo pipefail
FORMAT="lines"
CONFIG_FILE="config/images.yaml"
for a in "$@"; do
  if [[ "$a" == "--json" ]]; then
    FORMAT="json"
  else
    CONFIG_FILE="$a"
  fi
done

if [ ! -f "$CONFIG_FILE" ]; then
  echo "ERROR: $CONFIG_FILE not found" >&2
  exit 1
fi
if ! command -v yq &>/dev/null; then
  echo "ERROR: yq not installed" >&2
  exit 1
fi

if [[ "$FORMAT" == "json" ]]; then
  # Output JSON array [{"image":"debian-13","arch":"amd64"}, ...] for GHA matrix
  first=true
  echo -n '['
  for img in $(yq -r '.images | keys | .[]' "$CONFIG_FILE"); do
    for arch in $(yq -r ".images.${img} | keys | .[]" "$CONFIG_FILE"); do
      $first || echo -n ','
      echo -n "{\"image\":\"$img\",\"arch\":\"$arch\"}"
      first=false
    done
  done
  echo ']'
else
  for img in $(yq -r '.images | keys | .[]' "$CONFIG_FILE"); do
    for arch in $(yq -r ".images.${img} | keys | .[]" "$CONFIG_FILE"); do
      echo "${img} ${arch}"
    done
  done
fi
