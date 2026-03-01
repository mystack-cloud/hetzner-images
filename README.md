# Metal Images

Build pipeline for custom Hetzner dedicated server images installable via [installimage](https://docs.hetzner.com/robot/dedicated-server/operating-systems/installimage/).

Uses the **Hetzner bootimages mirror** (`download.hetzner.com/bootimages`) to download official base tarballs, optionally customizes them via `docker build`, and can re-export the result as an installimage-compatible `.tar.gz`. Base images are **synced monthly** to the repository’s Docker registry (GitHub Container Registry) with **multi-arch** support (amd64 and arm64 where available).

## Images

| Image | Base | Description |
|-------|------|-------------|
| Debian 13 | Hetzner Debian 13 (Trixie) | Debian 13 base image |

## Prerequisites

- [Docker](https://www.docker.com/) with [Docker Compose](https://docs.docker.com/compose/)

No KVM, QEMU, Packer, or Ansible required. All build dependencies are handled inside Docker containers.

## Base image sync (monthly)

A scheduled workflow runs **once a month** (1st at 03:00 UTC) and:

1. Downloads all configured Hetzner bootimages from the mirror (see `config/images.yaml`)
2. Imports each tarball as a Docker image per architecture (amd64 / arm64)
3. Pushes arch-specific images to **GitHub Container Registry**: `ghcr.io/<owner>/<repo>/<image>:<arch>`
4. Creates and pushes **multi-arch manifest lists**: `ghcr.io/<owner>/<repo>/<image>:latest`

So you can pull a single tag and get the right architecture:

```bash
docker pull ghcr.io/<owner>/<repo>/debian-13:latest
```

You can also run the workflow manually: **Actions → Sync Hetzner Base Images → Run workflow**.

## Building locally

```bash
# 1. Download and import a Hetzner base image (cached in dist/)
docker compose run --rm download debian-13 amd64

# 2. (Optional) Tag for single-arch build: metal-base:<image>
docker tag metal-base:debian-13-amd64 metal-base:debian-13

# 3. Build the customized image
docker compose run --rm build debian-13
```

The resulting tarball is in `dist/debian-13-amd64-base.tar.gz`.

### Images in registry

The following images are defined in **`config/images.yaml`** and are synced to GHCR (monthly and on demand). The `download` service supports all listed image/arch pairs.

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

## CI/CD

- **Sync Hetzner Base Images** (`.github/workflows/sync-base-images.yml`): runs monthly (1st at 03:00 UTC) and on demand; downloads bootimages and pushes multi-arch images to GHCR.

### Required secrets

Under **Settings → Secrets and variables → Actions**:

| Secret | Description |
|--------|-------------|
| `HETZNER_MIRROR_USER` | Hetzner mirror username |
| `HETZNER_MIRROR_PASS` | Hetzner mirror password |

## How it works

1. **download**: downloads a tarball from `https://download.hetzner.com/bootimages/` and imports it as `metal-base:<image>-<arch>`.
2. **build**: runs `docker build` with the image-specific Dockerfile (`Dockerfile.<image>`) and exports a compressed tarball.

## Adding a new image

1. Add the image and its arch(s) to `config/images.yaml` (and to the fallback in `scripts/download.sh` if needed).
2. Download locally: `docker compose run --rm download <image> [arch]`
3. For a custom image: add `Dockerfile.<image-name>` with `FROM metal-base:<base>`. The sync workflow uses `config/images.yaml` for the image set.

## Project structure

```
.
├── .github/workflows/
│   └── sync-base-images.yml   # Bootimages → GHCR (monthly + manual)
├── config/
│   └── images.yaml            # Image/arch → Hetzner bootimage filename
├── Dockerfile                 # Tool image (curl, Docker CLI, yq)
├── Dockerfile.debian-13       # Debian 13 image recipe (if present)
├── docker-compose.yml         # download, build
├── scripts/
│   ├── build.sh               # Build + export
│   ├── download.sh            # Download from Hetzner mirror + docker import
│   └── list.sh                # List image/arch from config (for CI matrix)
```
