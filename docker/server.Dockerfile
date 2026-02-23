# Check latest version here: https://pypi.org/project/qlever/
ARG QLEVER_VERSION="0.5.45"

# Check latest pipx version here: https://github.com/pypa/pipx/releases
ARG PIPX_VERSION="1.8.0"

ARG SOPHIA_CLI_VERSION="2cf13ac19e4f1e61b502267a2f6381e84993d1b1"

FROM rust:bookworm AS sophia-cli-builder

WORKDIR /app

ARG SOPHIA_CLI_VERSION

# Fetch source code of sophia-cli, in order to build it and have it available in the final image
RUN git init \
  && git remote add origin https://github.com/pchampin/sophia-cli.git \
  && git fetch --depth 1 origin "${SOPHIA_CLI_VERSION}" \
  && git checkout FETCH_HEAD \
  && rm -rf .git
RUN cargo build --release

# Dependency images
FROM ghcr.io/ludovicm67/stop-on-call:v0.1.0 AS soc
FROM index.docker.io/adfreiburg/qlever:latest@sha256:b3468980c2b4b643defbc286c3c45f6b541ca57a2fb5782154d5ba66f7cc0d11 AS qlever

# Final image
FROM ubuntu:24.04
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
COPY --from=qlever /qlever/qlever-index /qlever/qlever-server /qlever/*Main /qlever/
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

# Add sophia-cli to the image
COPY --from=sophia-cli-builder /app/target/release/sop /usr/bin/sop

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
