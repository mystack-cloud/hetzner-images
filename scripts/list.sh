#!/usr/bin/env bash
# Reads config/images.yaml and outputs image/arch pairs.
# Usage: list.sh [config] [--json]
#   Default: one line per "image arch". With --json: JSON array for GHA matrix.

set -euo pipefail
FORMAT="lines"
CONFIG_FILE="config/images.yaml"
for a in "$@"; do
  case "$a" in
    --json)
      FORMAT="json"
      ;;
    -*)
      echo "ERROR: Unknown option: $a" >&2
      exit 2
      ;;
    *)
      CONFIG_FILE="$a"
      ;;
  esac
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
  # Output compact JSON array [{"image":"debian-13","arch":"amd64"}, ...] for GHA matrix
  yq -o=json -I=0 '
    .images as $images
    | [ $images | keys | .[] as $img
        | ($images[$img] | keys | .[] as $arch
            | {"image": $img, "arch": $arch}
          )
      ]
  ' "$CONFIG_FILE"
else
  yq -r '
    .images as $images
    | $images | keys | .[] as $img
    | ($images[$img] | keys | .[] as $arch | "\($img) \($arch)")
  ' "$CONFIG_FILE"
fi
