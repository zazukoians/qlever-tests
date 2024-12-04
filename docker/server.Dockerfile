# Check latest version here: https://pypi.org/project/qlever/
ARG QLEVER_VERSION="0.5.12"

FROM index.docker.io/adfreiburg/qlever:latest@sha256:f89db3fd6218f1b9e00a602b55a1cfc2316f32a12f729e011f3cc4d268acd053

ARG QLEVER_VERSION

USER root

# Install python3 and pip3, in order to install qlever
RUN apt-get update \
  && apt-get install -y \
  python3 \
  python3-pip \
  && rm -rf /var/lib/apt/lists/*
RUN pip3 install "qlever==${QLEVER_VERSION}"

# Just make sure that the user qlever has a home directory, so that we can enable autocompletion
RUN mkdir -p /home/qlever/data && chown -R qlever:qlever /home/qlever
RUN echo 'eval "$(register-python-argcomplete qlever)"' >> /home/qlever/.bashrc
ENV QLEVER_ARGCOMPLETE_ENABLED=1

# Include some useful scripts
RUN mkdir -p /home/qlever/scripts
COPY ./common/generate-qleverfile.sh /home/qlever/scripts/
COPY ./server/entrypoint.sh /home/qlever/scripts/
RUN chmod +x /home/qlever/scripts/*.sh

# Switch back to the qlever user
USER qlever

WORKDIR /home/qlever

EXPOSE 7001

ENTRYPOINT [ "" ]
CMD [ "/home/qlever/scripts/entrypoint.sh" ]
