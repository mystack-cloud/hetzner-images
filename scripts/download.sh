#!/usr/bin/env bash
set -euo pipefail

# Usage: download.sh <image> [arch]
# Example: download.sh debian-13 amd64
# Downloads Hetzner bootimage tarball and imports as Docker image metal-base:<image>-<arch>

IMAGE="${1:?Usage: $0 <image> [arch]}"
ARCH="${2:-amd64}"

HETZNER_MIRROR_USER="${HETZNER_MIRROR_USER:?HETZNER_MIRROR_USER must be set}"
HETZNER_MIRROR_PASS="${HETZNER_MIRROR_PASS:?HETZNER_MIRROR_PASS must be set}"
HETZNER_BASE="https://${HETZNER_MIRROR_USER}:${HETZNER_MIRROR_PASS}@download.hetzner.com/bootimages"

CONFIG_FILE="config/images.yaml"
if command -v yq &>/dev/null && [ -f "$CONFIG_FILE" ]; then
  BASE_FILE=$(IMAGE="$IMAGE" ARCH="$ARCH" yq -r '.images[env(IMAGE)][env(ARCH)] // ""' "$CONFIG_FILE")
  if [ -z "$BASE_FILE" ]; then
    echo "ERROR: No config for image=${IMAGE} arch=${ARCH} in ${CONFIG_FILE}"
    exit 1
  fi
else
  echo "ERROR: yq and ${CONFIG_FILE} are required"
  exit 1
fi

BASE_URL="${HETZNER_BASE}/${BASE_FILE}"
OUTPUT_FILE="dist/${BASE_FILE}"
DOCKER_TAG="metal-base:${IMAGE}-${ARCH}"

mkdir -p dist
if [ ! -f "$OUTPUT_FILE" ]; then
  echo "==> Downloading ${BASE_FILE}..."
  curl -fSL -o "$OUTPUT_FILE" "$BASE_URL"
else
  echo "==> Using cached ${OUTPUT_FILE}"
fi

echo "==> Importing base image as ${DOCKER_TAG}..."
docker import "$OUTPUT_FILE" "$DOCKER_TAG"

echo "==> Base image ready: ${DOCKER_TAG}"
