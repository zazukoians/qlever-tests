# Check latest version here: https://pypi.org/project/qlever/
ARG QLEVER_VERSION="0.6.0"

# Check latest pipx version here: https://github.com/pypa/pipx/releases
ARG PIPX_VERSION="1.17.2"

# Check latest version here: https://github.com/pchampin/sophia-cli/releases
ARG SOPHIA_CLI_VERSION="v0.1.0-alpha3"

# Dependency images
FROM ghcr.io/ludovicm67/stop-on-call:v0.1.0 AS soc
FROM index.docker.io/adfreiburg/qlever:latest@sha256:faebf9a1d36dae584b06074dc79a303e968f93c6e53135e2f4edd90d256d80c1 AS qlever

# Final image
FROM ubuntu:26.04
ARG QLEVER_VERSION
ARG PIPX_VERSION

ENV DEBIAN_FRONTEND="noninteractive"

# Upgrade and install necessary packages
RUN apt-get update \
  && apt-get upgrade -y \
  && apt-get install -y \
  bash-completion \
  bzip2 \
  curl \
  libboost-iostreams1.83.0 \
  libboost-program-options1.83.0 \
  libboost-url1.83.0 \
  libgomp1 \
  libicu74 \
  libjemalloc2 \
  liburing2 \
  libzstd1 \
  pipx \
  python3 \
  unzip \
  uuid-runtime \
  vim \
  wget \
  && apt-get autoremove -y \
  && rm -rf /var/lib/apt/lists/* \
  && apt-get clean

# Just make sure that the user that will be running the container will have the necessary permissions
RUN mkdir -p /qlever /data \
  && chmod -R a+rw /data \
  && chmod -R a+rw /qlever
RUN echo 'eval "$(register-python-argcomplete qlever)"' >> /etc/bash.bashrc
RUN echo 'PATH="/qlever:${PATH}"' >> /etc/bash.bashrc
ENV QLEVER_ARGCOMPLETE_ENABLED="1"
ENV QLEVER_IS_RUNNING_IN_CONTAINER="1"

# Upgrade pipx (to have the `--global` option)
RUN curl -L -o /usr/local/bin/pipx "https://github.com/pypa/pipx/releases/download/${PIPX_VERSION}/pipx.pyz" \
  && chmod +x /usr/local/bin/pipx

# Install QLever
COPY --from=qlever /qlever/qlever-* /qlever/*Main /qlever/
ENV PATH="/qlever:${PATH}"
RUN pipx install --global "qlever==${QLEVER_VERSION}"

# Include some useful scripts
RUN mkdir -p /qlever/scripts
COPY ./common/generate-qleverfile.sh /qlever/scripts/
COPY ./server/entrypoint.sh /qlever/scripts/
RUN chmod +x /qlever/scripts/*.sh

# Configure Stop On Call
ENV STOP_ON_CALL_ENABLED="false"
COPY --from=soc /app/stop_on_call /usr/bin/stop_on_call

# Add sophia-cli (sop) from the upstream release, picking the prebuilt binary that
# matches the target architecture. Releases: https://github.com/pchampin/sophia-cli/releases
ARG SOPHIA_CLI_VERSION
ARG TARGETARCH
RUN set -eux; \
  case "${TARGETARCH}" in \
  amd64) SOP_TARGET="x86_64-unknown-linux-gnu" ;; \
  arm64) SOP_TARGET="aarch64-unknown-linux-gnu" ;; \
  *) echo "ERROR: unsupported TARGETARCH '${TARGETARCH}' for sophia-cli" >&2; exit 1 ;; \
  esac; \
  SOP_TARBALL="sop-${SOP_TARGET}.tar.gz"; \
  curl -fsSL -o "/tmp/${SOP_TARBALL}" \
  "https://github.com/pchampin/sophia-cli/releases/download/${SOPHIA_CLI_VERSION}/${SOP_TARBALL}"; \
  tar -xzf "/tmp/${SOP_TARBALL}" -C /usr/bin sop; \
  chmod +x /usr/bin/sop; \
  rm -f "/tmp/${SOP_TARBALL}"

# Use the nobody user by default
USER 65534

WORKDIR /qlever

EXPOSE 7001

# Default environment variables
ENV QLEVER_SERVER_HOST_NAME="127.0.0.1"
ENV QLEVER_SERVER_PORT="7001"
ENV QLEVER_RUNTIME_SYSTEM="native"

ENTRYPOINT [ "" ]
CMD [ "/qlever/scripts/entrypoint.sh" ]
