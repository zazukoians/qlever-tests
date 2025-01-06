FROM docker.io/denoland/deno:2.1.4

EXPOSE 7003
WORKDIR /app

USER deno

COPY main.ts ./
RUN deno cache main.ts

CMD [ "run", "--allow-net", "--allow-env", "main.ts" ]
