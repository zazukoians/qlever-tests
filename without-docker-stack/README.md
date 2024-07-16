# Using the `qlever` CLI

## Start venv and Qlever

Install dependencies in a virtual environment:

```sh
poetry shell
poetry install
```

The `Qleverfile` file was generated by using the following commands:

```sh
rm -f Qleverfile
qlever setup-config olympics
```

And some changes were made according to the [Troubleshooting](#troubleshooting) section.

Then, you can run the following commands:

```sh
qlever get-data # Download the data according to `data.GET_DATA_CMD` in the `Qleverfile`
qlever index # Index the data
qlever start # Start the QLever server

qlever example-queries
qlever ui
```

## Troubleshooting

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

### `docker` reports operation not permitted

If you get an error like `docker: Error response from daemon: operation not permitted`, you may need to add your user to the `docker` group.

Relevant link: https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user

This is because the `qlever` CLI assumes that your current user is able to run `docker` commands without `sudo`.

Or you might want to run all `qlever` commands prefixed with `sudo ` instead.

## Conclusion

The `qlever` CLI is just a wrapper around the `docker` commands, so you can also use the `docker` commands directly to start the QLever server and the UI.

The easiest way would be to use a Docker Compose stack, as described in the [README.md](../README.md) file, as it will take care of everything for you, including of all parameters.