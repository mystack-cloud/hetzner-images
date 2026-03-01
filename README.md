# Hetzner Images

[![Sync base images](https://github.com/mystack-cloud/hetzner-images/actions/workflows/sync-base-images.yml/badge.svg)](https://github.com/mystack-cloud/hetzner-images/actions/workflows/sync-base-images.yml)

**Container registry of standard Hetzner bootimages** — downloaded from the [Hetzner bootimages mirror](https://download.hetzner.com/bootimages/) and published to GitHub Container Registry (GHCR) as multi-arch images. No custom build step: this repository only syncs official Hetzner base tarballs into a container registry.

You can use them as base images in Docker builds. Use [container-registry.sh](https://github.com/mystack-cloud/container-registry.sh) to download any Docker image (including custom images you built from these bases) from a registry to a Hetzner root server in rescue mode, in a format the [Hetzner installimage](https://github.com/hetzneronline/installimage) script understands.

## Images in registry

The following images are synced to **ghcr.io/\<owner\>/\<repo\>/\<image\>:latest** (and per-arch tags). The table is updated by the sync workflow.

<!-- REGISTRY_IMAGES -->
| Image | Architectures |
|-------|---------------|
| `alma-10` | amd64 |
| `alma-8` | amd64 |
| `alma-9` | amd64 |
| `centos-10` | amd64 |
| `centos-9` | amd64 |
| `debian-11` | amd64,arm64 |
| `debian-12` | amd64,arm64 |
| `debian-13` | amd64,arm64 |
| `opensuse-15` | amd64 |
| `opensuse-16` | amd64 |
| `rocky-10` | amd64 |
| `rocky-8` | amd64 |
| `rocky-9` | amd64 |
| `ubuntu-2204` | amd64,arm64 |
| `ubuntu-2404` | amd64,arm64 |
<!-- /REGISTRY_IMAGES -->

To add or change images or architectures, edit `config/images.yaml` (and the fallback list in `scripts/download.sh` if not using yq).

## Pulling images

**With Docker:**

```bash
docker pull ghcr.io/<owner>/<repo>/debian-13:latest
```

**Without Docker (e.g. Hetzner root server in rescue mode):**

Use [container-registry.sh](https://github.com/mystack-cloud/container-registry.sh) to pull images as Docker-format tarballs (no daemon required):

```bash
curl -fsSL https://get.container-registry.sh | sh -s
container-registry.sh pull -u USER:TOKEN ghcr.io/<owner>/<repo>/debian-13:latest
# Load into Docker if available: docker load -i <output>.tar.gz
```

For private GHCR images, use a [Personal Access Token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) with `read:packages` as the password.

## Custom images

To build your own image (custom packages, files, etc.), use one of the images from this registry as the base in a Dockerfile:

```dockerfile
FROM ghcr.io/<owner>/<repo>/debian-13:latest
RUN apt-get update && apt-get install -y your-packages
COPY your-files /target/
```

Build and push with your usual tooling; no build step is provided in this repository.

## Base image sync (monthly)

A scheduled workflow runs **once a month** (1st at 03:00 UTC) and on demand:

1. Downloads configured Hetzner bootimages from the mirror (`config/images.yaml`)
2. Imports each tarball as a Docker image per architecture (amd64 / arm64)
3. Pushes arch-specific images to GHCR: `ghcr.io/<owner>/<repo>/<image>:<arch>`
4. Creates multi-arch manifest lists: `ghcr.io/<owner>/<repo>/<image>:latest`

**Run manually:** Actions → Sync Hetzner Base Images → Run workflow.

### Required secrets

Under **Settings → Secrets and variables → Actions**:

| Secret | Description |
|--------|-------------|
| `HETZNER_MIRROR_USER` | Hetzner mirror username |
| `HETZNER_MIRROR_PASS` | Hetzner mirror password |

## Local download (optional)

To download and import a single base image locally (e.g. for testing):

```bash
export HETZNER_MIRROR_USER=your-user HETZNER_MIRROR_PASS=your-pass
docker compose run --rm download debian-13 amd64
```

This produces `metal-base:debian-13-amd64` and caches the tarball in `dist/`.

## Project structure

```
.
├── .github/workflows/
│   └── sync-base-images.yml   # Bootimages → GHCR (monthly + manual)
├── config/
│   └── images.yaml            # Image/arch → Hetzner bootimage filename
├── Dockerfile                 # Tool image for download service (curl, Docker CLI, yq)
├── docker-compose.yml         # download service
├── scripts/
│   ├── download.sh            # Download from Hetzner mirror + docker import
│   └── list.sh                # List image/arch from config (for CI matrix)
└── test/
    └── scripts/
        └── test-prepare.sh     # Test prepare-job logic locally
```
