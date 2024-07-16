# QLever tests

## Using Docker Compose to run QLever

The `qlever` command is using Docker under the hood to spawn the QLever server and the UI.

By inspecting how the `qlever` command is implemented, we can see a bit how the different parts are started.

You can get rid of the `qlever` command and start the QLever server and UI directly by using the Docker Compose stack.

Put your data in the `docker/server/data.nq` file, and run the following commands:

```sh
docker compose pull # Just make sure we are using the latest images
docker compose up # Start the stack
```

And then you can access the UI at `http://localhost:7002`.

To stop the stack, you can use:

```sh
docker compose down
```

Using the Docker Compose stack is the easiest way to start the QLever server and the UI.
