#!/usr/bin/env bash
set -euo pipefail

IMAGE="${1:-ubuntu-2404}"
BUILD_IMAGE="metal-image:${IMAGE}"
OUTPUT_DIR="dist"

# Build customized image
echo "==> Building image..."
docker build -f "Dockerfile.${IMAGE}" -t "$BUILD_IMAGE" .

# Export as tarball
echo "==> Exporting image..."
mkdir -p "$OUTPUT_DIR"
CONTAINER_ID=$(docker create "$BUILD_IMAGE" /bin/true)
docker export "$CONTAINER_ID" | gzip > "${OUTPUT_DIR}/${IMAGE}-amd64-base.tar.gz"
docker rm "$CONTAINER_ID" > /dev/null

echo "==> Build complete: ${OUTPUT_DIR}/${IMAGE}-amd64-base.tar.gz"
