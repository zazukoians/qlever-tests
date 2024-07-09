# QLever tests

## Using Docker Compose to run QLever

The `qlever` command is using Docker under the hood to spawn the QLever server and the UI.

By inspecting how the `qlever` command is implemented, we can see a bit how the different parts are started.

You can get rid of the `qlever` command and start the QLever server and UI directly by using the Docker Compose stack:

```sh
docker compose up
```

And then you can access the UI at `http://localhost:7002`.

To stop the stack, you can use:

```sh
docker compose down
```

Using the Docker Compose stack is the easiest way to start the QLever server and the UI.

## Using the `qlever` CLI

### Start venv and Qlever

```sh
poetry shell
poetry install

qlever setup-config olympics
qlever get-data
qlever index
qlever start

qlever example-queries
qlever ui
```

### Changes to do in the `Qleverfile` file

When you run the `qlever setup-config …` command, a `Qleverfile` file is created in the current directory.

The `Qleverfile` file is a configuration file that is used by the `qlever` command to start the QLever server and the UI, so that it provides some configuration to both services (server and UI).

The default `Qleverfile` file may need some changes to work properly.

See the following points for some changes that may be needed.

#### `ui.UI_PORT`

On MacOS, the UI is not able to start on port 7000, which is the default value, as something else might already be using that port.
To solve this, in the `[ui]` section of the `Qleverfile` file, change/set the `UI_PORT` value to something else, like: `UI_PORT=7002`.

#### `server.HOST_NAME`

It seems that there is an issue for the UI to connect to the server when the `HOST_NAME` doesn't have a specified value.

To solve this, in the `[server]` section of the `Qleverfile` file, change/set the `HOST_NAME` value to `HOST_NAME=localhost`.
