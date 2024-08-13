# QLever tests

## Using Docker Compose to run QLever

### Local file

The `qlever` command is using Docker under the hood to spawn the QLever server and the UI.

By inspecting how the `qlever` command is implemented, we can see a bit how the different parts are started.

You can get rid of the `qlever` command and start the QLever server and UI directly by using the Docker Compose stack.

Put your data in the `docker/server/data.nq` file, and run the following commands:

```sh
docker compose --profile local build # Just make sure we are using the latest images
docker compose --profile local up # Start the stack
```

And then you can access the UI at `http://localhost:7002`.

To stop the stack, you can use:

```sh
docker compose --profile local down
```

Using the Docker Compose stack is the easiest way to start the QLever server and the UI.

### Olympics demo

The Docker Compose Stack is also able to run the Olympics demo.

Just run the following commands:

```sh
docker compose --profile olympics build # Just make sure we are using the latest images
docker compose --profile olympics up # Start the stack
```

And then you can access the UI at `http://localhost:7002`.

To stop the stack, you can use:

```sh
docker compose --profile olympics down
```

## Next steps

This could be interesting to use a distroless base image for the QLever server and the UI, but it would be better that the server and the UI are able to get the configuration from the environment variables, like we do using some shell scripts as entrypoint, but natively.

So in the current state, this is not a good idea, as there is no shell.
Using our custom entrypoints will not work as there is no shell to interpret the scripts.
We should wait that the server and the UI are updated first.

We should instead focus on:

- having the images run as a non-root user
  - [x] the server ; UID/GID `1000`
  - [ ] the UI ; not yet, as it is not able to access the database
- update base of the images to latest versions
- make sure that the images are built for `amd64` and `arm64` architectures:
  - [x] the server
  - [ ] the UI ; only `amd64` for now
