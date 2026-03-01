# Tool image for downloading Hetzner bootimages and importing into Docker.
# Used by docker-compose service: download.
FROM docker:24-cli
RUN apk add --no-cache curl bash
# Install yq for parsing config/images.yaml (mikefarah/yq)
ARG YQ_VERSION=v4.44.1
RUN curl -sSL "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64" -o /usr/local/bin/yq \
  && chmod +x /usr/local/bin/yq
WORKDIR /workspace
