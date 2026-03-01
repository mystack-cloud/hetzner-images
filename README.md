# Hetzner Images

[![Sync base images](https://github.com/mystack-cloud/hetzner-images/actions/workflows/sync-base-images.yml/badge.svg)](https://github.com/mystack-cloud/hetzner-images/actions/workflows/sync-base-images.yml) [![Scan images](https://github.com/mystack-cloud/hetzner-images/actions/workflows/scan-images.yml/badge.svg)](https://github.com/mystack-cloud/hetzner-images/actions/workflows/scan-images.yml)

**Container registry of standard Hetzner bootimages** — downloaded from the [Hetzner bootimages mirror](https://download.hetzner.com/bootimages/) and published to GitHub Container Registry (GHCR) as multi-arch images. No custom build step: this repository only syncs official Hetzner base tarballs into a container registry.

You can use them as base images in Docker builds. Use [container-registry.sh](https://github.com/mystack-cloud/container-registry.sh) to download any Docker image (including custom images you built from these bases) from a registry to a Hetzner root server in rescue mode, in a format the [Hetzner installimage](https://github.com/hetzneronline/installimage) script understands.

## Images in registry

The following images are synced to **ghcr.io/\<owner\>/\<repo\>/\<image\>:latest** (and per-arch tags). The table is updated by the sync workflow.

<!-- REGISTRY_IMAGES -->
| Image | Architectures | Critical |
|-------|---------------|----------|
| [alma-10](https://ghcr.io/mystack-cloud/hetzner-images/alma-10:latest) | amd64 | ![](https://img.shields.io/endpoint?url=https%3A//raw.githubusercontent.com/mystack-cloud/hetzner-images/main/badges/alma-10.json) |
| [alma-8](https://ghcr.io/mystack-cloud/hetzner-images/alma-8:latest) | amd64 | ![](https://img.shields.io/endpoint?url=https%3A//raw.githubusercontent.com/mystack-cloud/hetzner-images/main/badges/alma-8.json) |
| [alma-9](https://ghcr.io/mystack-cloud/hetzner-images/alma-9:latest) | amd64 | ![](https://img.shields.io/endpoint?url=https%3A//raw.githubusercontent.com/mystack-cloud/hetzner-images/main/badges/alma-9.json) |
| [centos-10](https://ghcr.io/mystack-cloud/hetzner-images/centos-10:latest) | amd64 | ![](https://img.shields.io/endpoint?url=https%3A//raw.githubusercontent.com/mystack-cloud/hetzner-images/main/badges/centos-10.json) |
| [centos-9](https://ghcr.io/mystack-cloud/hetzner-images/centos-9:latest) | amd64 | ![](https://img.shields.io/endpoint?url=https%3A//raw.githubusercontent.com/mystack-cloud/hetzner-images/main/badges/centos-9.json) |
| [debian-11](https://ghcr.io/mystack-cloud/hetzner-images/debian-11:latest) | amd64,arm64 | ![](https://img.shields.io/endpoint?url=https%3A//raw.githubusercontent.com/mystack-cloud/hetzner-images/main/badges/debian-11.json) |
| [debian-12](https://ghcr.io/mystack-cloud/hetzner-images/debian-12:latest) | amd64,arm64 | ![](https://img.shields.io/endpoint?url=https%3A//raw.githubusercontent.com/mystack-cloud/hetzner-images/main/badges/debian-12.json) |
| [debian-13](https://ghcr.io/mystack-cloud/hetzner-images/debian-13:latest) | amd64,arm64 | ![](https://img.shields.io/endpoint?url=https%3A//raw.githubusercontent.com/mystack-cloud/hetzner-images/main/badges/debian-13.json) |
| [opensuse-15](https://ghcr.io/mystack-cloud/hetzner-images/opensuse-15:latest) | amd64 | ![](https://img.shields.io/endpoint?url=https%3A//raw.githubusercontent.com/mystack-cloud/hetzner-images/main/badges/opensuse-15.json) |
| [opensuse-16](https://ghcr.io/mystack-cloud/hetzner-images/opensuse-16:latest) | amd64 | ![](https://img.shields.io/endpoint?url=https%3A//raw.githubusercontent.com/mystack-cloud/hetzner-images/main/badges/opensuse-16.json) |
| [rocky-10](https://ghcr.io/mystack-cloud/hetzner-images/rocky-10:latest) | amd64 | ![](https://img.shields.io/endpoint?url=https%3A//raw.githubusercontent.com/mystack-cloud/hetzner-images/main/badges/rocky-10.json) |
| [rocky-8](https://ghcr.io/mystack-cloud/hetzner-images/rocky-8:latest) | amd64 | ![](https://img.shields.io/endpoint?url=https%3A//raw.githubusercontent.com/mystack-cloud/hetzner-images/main/badges/rocky-8.json) |
| [rocky-9](https://ghcr.io/mystack-cloud/hetzner-images/rocky-9:latest) | amd64 | ![](https://img.shields.io/endpoint?url=https%3A//raw.githubusercontent.com/mystack-cloud/hetzner-images/main/badges/rocky-9.json) |
| [ubuntu-2204](https://ghcr.io/mystack-cloud/hetzner-images/ubuntu-2204:latest) | amd64,arm64 | ![](https://img.shields.io/endpoint?url=https%3A//raw.githubusercontent.com/mystack-cloud/hetzner-images/main/badges/ubuntu-2204.json) |
| [ubuntu-2404](https://ghcr.io/mystack-cloud/hetzner-images/ubuntu-2404:latest) | amd64,arm64 | ![](https://img.shields.io/endpoint?url=https%3A//raw.githubusercontent.com/mystack-cloud/hetzner-images/main/badges/ubuntu-2404.json) |
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

## Security scanning

A weekly workflow (**Scan images**) runs [Trivy](https://github.com/aquasecurity/trivy) against each image in the registry. Findings appear in **Security → Code scanning**, in each scan job’s **summary**, and as **artifacts** (per-image reports, 30-day retention). Schedule: Sundays 04:00 UTC; can also be triggered manually.

## Project structure

```
.
├── .github/workflows/
│   ├── scan-images.yml        # Trivy vulnerability scan (weekly + manual)
│   ├── sync-base-images.yml   # Bootimages → GHCR (monthly + manual)
│   └── update-readme.yml      # Update README table (standalone or after sync)
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
