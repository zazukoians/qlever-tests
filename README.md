## Start venv and Qlever

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

## Changes to do in the `Qleverfile` file

### `ui.UI_PORT`

On MacOS, the UI is not able to start on port 7000, which is the default value.
To solve this, in the `[ui]` section of the `Qleverfile` file, change/set the `UI_PORT` value to something else, like: `UI_PORT=7002`.

### `server.HOST_NAME`

It seems that there is an issue for the UI to connect to the server when the `HOST_NAME` doesn't have a specified value.

To solve this, in the `[server]` section of the `Qleverfile` file, change/set the `HOST_NAME` value to `HOST_NAME=localhost`.
