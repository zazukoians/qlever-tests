# Check latest version here: https://pypi.org/project/qlever/
ARG QLEVER_VERSION="0.5.23"

FROM index.docker.io/adfreiburg/qlever-ui:latest@sha256:a51cbe816415194e98df92fc59cf2f5a157e53de4c8d845720a509c81ab28a93

ARG QLEVER_VERSION

USER root

# Install python3 and pip3, in order to install qlever
RUN apk add --no-cache \
  curl \
  python3 \
  py3-pip \
  gcc python3-dev musl-dev linux-headers
RUN pip3 install "qlever==${QLEVER_VERSION}"

# Just make sure that the user that will be running the container will have the necessary permissions
RUN mkdir -p /qlever /data \
  && chmod -R a+rw /data \
  && chmod -R a+rw /qlever
RUN echo 'eval "$(register-python-argcomplete qlever)"' >> /qlever/.bashrc
ENV QLEVER_ARGCOMPLETE_ENABLED="1"
ENV QLEVER_IS_RUNNING_IN_CONTAINER="1"

# Make sure that current user owns the db directory
# And move the default database to another location
# It will be copied back to the db directory if it does not exist
RUN chmod -R a+rw /app/db \
  && mkdir -p /app/default \
  && mv /app/db/qleverui.sqlite3 /app/default/qleverui.sqlite3

# Include some useful scripts
RUN mkdir -p /qlever/scripts
COPY ./common/generate-qleverfile.sh /qlever/scripts/
COPY ./ui/entrypoint.sh /qlever/scripts/
RUN chmod +x /qlever/scripts/*.sh
COPY ./ui/docker.sh /usr/bin/docker
RUN chmod +x /usr/bin/docker

# Use the nobody user by default
USER 65534

WORKDIR /qlever

COPY ./ui/update.py /app/backend/management/commands/update.py

EXPOSE 7002

ENTRYPOINT [ "" ]
CMD [ "/qlever/scripts/entrypoint.sh" ]
