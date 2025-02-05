FROM ghcr.io/ludovicm67/stop-on-call:v0.1.0 AS soc
FROM index.docker.io/adfreiburg/qlever:latest@sha256:6cd5edcdf5c0b94b1ba320388acfb57ea91c157593eb00c8d81cc3deab5b6da7

# Upgrade depdendencies and do some cleanup
USER root
RUN export SUDO_FORCE_REMOVE=yes \
  && apt-get update \
  && apt-get upgrade -y \
  && apt-get purge -y --auto-remove sudo \
  && rm -rf /var/lib/apt/lists/* \
  && apt-get clean \
  && unset SUDO_FORCE_REMOVE \
  && rm -f /etc/profile.d/qlever.sh /qlever/.bashrc /qlever/docker-entrypoint.sh

# Just make sure that the user that will be running the container will have the necessary permissions
RUN mkdir -p /qlever /data \
  && chmod -R a+rw /data \
  && chmod -R a+rw /qlever
RUN echo 'eval "$(register-python-argcomplete qlever)"' >> /qlever/.bashrc
ENV QLEVER_ARGCOMPLETE_ENABLED="1"
ENV QLEVER_IS_RUNNING_IN_CONTAINER="1"

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
