# QLever tests

## Using Docker Compose to run QLever

### Local file

It is possible to start the QLever server and the UI directly by using the Docker Compose stack.

Put your data in the `docker/server/data.nq` file, and run the following commands:

```sh
docker compose --profile local pull # Just make sure we are using the latest images
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
docker compose --profile olympics pull # Just make sure we are using the latest images
docker compose --profile olympics up # Start the stack
```

And then you can access the UI at `http://localhost:7002`.

To stop the stack, you can use:

```sh
docker compose --profile olympics down
```
