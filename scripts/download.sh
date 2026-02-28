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
  BASE_FILE=$(yq -r --arg image "$IMAGE" --arg arch "$ARCH" '.images[$image][$arch] // empty' "$CONFIG_FILE")
  if [ -z "$BASE_FILE" ]; then
    echo "ERROR: No config for image=${IMAGE} arch=${ARCH} in ${CONFIG_FILE}"
    exit 1
  fi
else
  # Fallback: static mapping (must match config/images.yaml)
  case "${IMAGE}-${ARCH}" in
    ubuntu-2404-amd64)   BASE_FILE="Ubuntu-2404-noble-amd64-base.tar.gz" ;;
    ubuntu-2404-arm64)   BASE_FILE="Ubuntu-2404-noble-arm64-base.tar.gz" ;;
    ubuntu-2204-amd64)   BASE_FILE="Ubuntu-2204-jammy-amd64-base.tar.gz" ;;
    ubuntu-2204-arm64)   BASE_FILE="Ubuntu-2204-jammy-arm64-base.tar.gz" ;;
    debian-13-amd64)     BASE_FILE="Debian-1303-trixie-amd64-base.tar.gz" ;;
    debian-13-arm64)     BASE_FILE="Debian-1303-trixie-arm64-base.tar.gz" ;;
    debian-12-amd64)     BASE_FILE="Debian-1213-bookworm-amd64-base.tar.gz" ;;
    debian-12-arm64)     BASE_FILE="Debian-1213-bookworm-arm64-base.tar.gz" ;;
    debian-11-amd64)     BASE_FILE="Debian-1111-bullseye-amd64-base.tar.gz" ;;
    debian-11-arm64)     BASE_FILE="Debian-1111-bullseye-arm64-base.tar.gz" ;;
    centos-10-amd64)     BASE_FILE="CentOS-1000-stream-amd64-base.tar.gz" ;;
    centos-9-amd64)      BASE_FILE="CentOS-90-stream-amd64-base.tar.gz" ;;
    rocky-10-amd64)      BASE_FILE="Rocky-1001-amd64-base.tar.gz" ;;
    rocky-9-amd64)       BASE_FILE="Rocky-97-amd64-base.tar.gz" ;;
    rocky-8-amd64)       BASE_FILE="Rocky-810-amd64-base.tar.gz" ;;
    alma-10-amd64)       BASE_FILE="Alma-1001-amd64-base.tar.gz" ;;
    alma-9-amd64)        BASE_FILE="Alma-97-amd64-base.tar.gz" ;;
    alma-8-amd64)        BASE_FILE="Alma-810-amd64-base.tar.gz" ;;
    opensuse-16-amd64)   BASE_FILE="Opensuse-1600-amd64-base.tar.gz" ;;
    opensuse-15-amd64)   BASE_FILE="Opensuse-1506-amd64-base.tar.gz" ;;
    *)
      echo "ERROR: Unknown image/arch: ${IMAGE}/${ARCH}"
      echo "Available: list in config/images.yaml or use image keys (e.g. debian-13, ubuntu-2404) with arch amd64 or arm64"
      exit 1
      ;;
  esac
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
