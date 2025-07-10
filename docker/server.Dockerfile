# Check latest version here: https://pypi.org/project/qlever/
ARG QLEVER_VERSION="0.5.23"

# Dependency images
FROM ghcr.io/ludovicm67/stop-on-call:v0.1.0 AS soc
FROM index.docker.io/adfreiburg/qlever:latest@sha256:40d73f4929ff30926cc8d142e08b9bb88d8cfcea75be1a509e835af0444752b9 AS qlever

# Final image
FROM ubuntu:24.10
ARG QLEVER_VERSION

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

# Install QLever
COPY --from=qlever /qlever/IndexBuilderMain /qlever/ServerMain /qlever/
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
