FROM ghcr.io/finleyfamily/docker-base-debian:v0.6.1@sha256:3d4c1cb6b5dde8b83c7409f8f02d396bd97e7f57455f9b1ef3364f51b84bc97f

###############################################################################
# Image Arguments                                                             #
# --------------------------------------------------------------------------- #
# Each arg must be defined in an "ARG" instruction for each stage before it
# can be used in the build stage.
#
# https://github.com/coder/code-server
# renovate: datasource=github-releases depName=coder/code-server versioning=loose
ARG CODE_SERVER_VERSION="v4.100.3"
ARG TARGETARCH

###############################################################################
# Install code-server                                                         #
# --------------------------------------------------------------------------- #
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# cspell:words firacode zxf
RUN set -ex; \
  echo "**** installing packages ****"; \
  apt-get update -y; \
  apt-get install --no-install-recommends -y \
    amazon-ecr-credential-helper \
    nmap \
    net-tools \
    openssh-client openssh-server \
    software-properties-common; \
  apt-add-repository contrib; \
  apt-get install --no-install-recommends -y fonts-firacode; \
  echo "**** installing code-server ****"; \
  if [[ "${TARGETARCH}" = "aarch64" ]] || [[ "${TARGETARCH}" = "arm64" ]]; then \
    export ARCH="arm64"; \
  else \
    export ARCH="amd64"; \
  fi; \
  curl -J -L -o /tmp/code.tar.gz \
    "https://github.com/coder/code-server/releases/download/${CODE_SERVER_VERSION}/code-server-${CODE_SERVER_VERSION#v}-linux-${ARCH}.tar.gz"; \
  mkdir -p /app/code-server; \
  tar zxf /tmp/code.tar.gz --strip-components 1 -C /app/code-server; \
  ln -s /app/code-server/bin/code-server /usr/local/bin/code-server; \
  echo "**** installing docker CLI ****"; \
  install -m 0755 -d /etc/apt/keyrings; \
  curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc; \
  chmod a+r /etc/apt/keyrings/docker.asc; \
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    tee /etc/apt/sources.list.d/docker.list > /dev/null; \
  apt-get update -y; \
  apt-get install --no-install-recommends -y docker-ce-cli docker-buildx-plugin docker-compose-plugin; \
  echo "**** performing cleanup ****"; \
  apt-get clean; \
  rm -rf /var/lib/apt/lists/*;

COPY rootfs/ /

ENTRYPOINT ["/init"]

###############################################################################
# Health check                                                                #
# --------------------------------------------------------------------------- #
HEALTHCHECK \
  CMD curl --fail http://127.0.0.1:80/healthz || exit 1

###############################################################################
# Expose ports                                                                #
# --------------------------------------------------------------------------- #
EXPOSE 22
EXPOSE 80
