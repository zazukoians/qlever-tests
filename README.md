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

## Customize using specific environment variables

Our custom container image for the server allows you to tweak the default behavior of the data download and the indexing using environment variables.

- `SHOULD_INDEX`: If set to `true`, the server will index the data. If set to `false`, the server will not index the data. If the data needs to be downloaded, then the value will be swicth to `true` in all cases. Default is `false`.
- `FORCE_INDEXING`: If set to `true`, the server will force the indexing of the data. Default is `false`.
- `SHOULD_DOWNLOAD`: If set to `true`, the server will download the data. If the input file already exists, then the value would be set to `false` automatically. Default is `true`.
- `FORCE_DOWNLOAD`: If set to `true`, the server will force the download of the data, even if `SHOULD_DOWNLOAD` is set to `false`. Default is `false`.

If you want to persist the data, you can mount a volume to the `/data` directory.

The custom image for the UI also offers some environment variables to customize the behavior:

- `MAP_VIEW_BASE_URL`: The base URL for the map view without trailing slash. Default is `""`, which will not display any button to open the map view.

## Relevant information about the QLever

- [Some features are still missing](https://github.com/ad-freiburg/qlever/issues/615), but are being worked on.
- [Current deviations from the SPARQL 1.1 standard](https://github.com/ad-freiburg/qlever/wiki/Current-deviations-from-the-SPARQL-1.1-standard)
