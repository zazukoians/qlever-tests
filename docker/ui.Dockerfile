# Check latest version here: https://pypi.org/project/qlever/
ARG QLEVER_VERSION="0.5.8"

FROM index.docker.io/adfreiburg/qlever-ui:latest@sha256:2980af1353585e3e173b016941fbbdeb5f84e45bf961e01706602425c1c5fbf3

ARG QLEVER_VERSION

USER root

# Install python3 and pip3, in order to install qlever
RUN apk add --no-cache \
  curl \
  python3 \
  py3-pip \
  gcc python3-dev musl-dev linux-headers
RUN pip3 install "qlever==${QLEVER_VERSION}"

# Just make sure that the user qlever has a home directory, so that we can enable autocompletion
RUN adduser -u 1000 -g 1000 -D qlever
RUN mkdir -p /home/qlever/data && chown -R qlever:qlever /home/qlever
RUN echo 'eval "$(register-python-argcomplete qlever)"' >> /home/qlever/.bashrc
ENV QLEVER_ARGCOMPLETE_ENABLED=1

# Make sure that qlever user owns the db directory
RUN chown -R qlever:qlever /app/db

# Include some useful scripts
RUN mkdir -p /home/qlever/scripts
COPY ./common/generate-qleverfile.sh /home/qlever/scripts/
COPY ./ui/entrypoint.sh /home/qlever/scripts/
RUN chmod +x /home/qlever/scripts/*.sh
COPY ./ui/docker.sh /usr/bin/docker
RUN chmod +x /usr/bin/docker

# Switch back to the qlever user
USER qlever

WORKDIR /home/qlever

EXPOSE 7002

ENTRYPOINT [ "" ]
CMD [ "/home/qlever/scripts/entrypoint.sh" ]
