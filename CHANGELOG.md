# qlever

## 0.9.1

### Patch Changes

- c39faa3: Bump server base image to `b346898`

## 0.9.0

### Minor Changes

- e37a139: Binaries were renamed to `qlever-index` and `qlever-server`
- 35d79bc: Bump server base image to `90c0cff`
- fb3f45e: Bump `qlever` CLI to 0.5.45

## 0.8.4

### Patch Changes

- ac5b85b: Upgrade UI base image to `a28aabe`
- 5178a0c: Upgrade qlever CLI to 0.5.43
- 26164cf: Upgrade server base image to `09303d5`

## 0.8.3

### Patch Changes

- d96090d: Bump server base image to e3b60e1
- 84b6b62: Upgrade qlever CLI to 0.5.33

## 0.8.2

### Patch Changes

- 5323291: Upgrade `qlever` CLI to 0.5.32
- 48510ee: Use ARG to configure pipx version
- 7636487: Upgrade pipx to 1.8.0
- ad0d486: Upgrade UI base image to `797c89c`
- e51bd55: Upgrade server base image to `99582d5`

## 0.8.1

### Patch Changes

- 40c017e: Use `eeadf22` as server base image

## 0.8.0

### Minor Changes

- 8b0c0b0: Various changes on the server image:

  - Use Ubuntu 24.04 as base image (downgrade from 24.10)
  - Upgrade pipx so that the `--global` option is available
  - Upgrade server base image to `d8f20f4`

### Patch Changes

- e3970a0: Upgrade UI base image to `3841dee` and `qlever` CLI to 0.5.24

## 0.7.0

### Minor Changes

- ac9848d: Change the way how the QLever server is started.
- ac9848d: Remove the `SHOW_LOGS` environment variable ; logs are shown by default.

### Patch Changes

- 8586449: Bump server base image to `382acdf`.
- ac9848d: Add `START_ADDITIONAL_ARGS` environment variable to configure additional arguments to the `qlever start` command.

## 0.6.2

### Patch Changes

- 47c4732: Bump server base image to `3bc8906`.

## 0.6.1

### Patch Changes

- 8379488: Update `PATH` directly in the Dockerfile, so that it includes `/qlever`
- 05d060c: Upgrade `server` base image to `7872df7`
- 8379488: Change order of steps in the Dockerfile

## 0.6.0

### Minor Changes

- 2ae3db4: Reduce size for server image

### Patch Changes

- dddb578: Bump server base image to `40d73f4`

## 0.5.14

### Patch Changes

- 79fecfd: Upgrade server base image to `f0a79a2`

## 0.5.13

### Patch Changes

- 1db872f: Upgrade server base image to `02361b6`
- ee2b2fa: Upgrade UI base image to `6992d93`

## 0.5.12

### Patch Changes

- 7ddfcac: Bump server base image to `a621b41`
- 0c71af5: Bump UI base image to `d506825`

## 0.5.11

### Patch Changes

- c8a7560: Upgrade qlever-control to 0.5.23 in the UI image.
- e152ca1: Upgrade UI base image to 1d6ed08
- ed70ff5: Upgrade server base image to 64a9a68

## 0.5.10

### Patch Changes

- cfad1f0: Bump UI server image from `607452e` to `274bb6b`.
- c6d8fec: Bump UI base image from `408ddf1` to `a51cbe8`.

## 0.5.9

### Patch Changes

- cf5b304: Upgrade UI base image to 408ddf1
- da577c0: Upgrade server base image to 607452e

## 0.5.8

### Patch Changes

- ece5f30: Bump UI base image to `0516203`
- 0c30c11: Bump server to `aa3a7f1`
- 7bba7de: Bump server base image to `5e69507`

## 0.5.7

### Patch Changes

- a2ab448: Bump qlever-control to 5.18
- 86ce176: Bump UI base image to `8fe9599`
- 6f6b709: Bump server base image to `4f3c3ed`

## 0.5.6

### Patch Changes

- 3b0c2f8: Fix: Handle case where `qlever start` is not giving the prompt back on error.
- 3b0c2f8: Show logs by default (could be disabled using `SHOW_LOGS=false`)

## 0.5.5

### Patch Changes

- 4146888: chore(deps): bump adfreiburg/qlever-ui from `2114bd3` to `5ab6e9a`
- ccc1b2d: chore(deps): bump adfreiburg/qlever from `526b36f` to `6cd5edc`
- 327c5e0: Bump qlever CLI to 0.5.17

## 0.5.4

### Patch Changes

- 7466945: Set some environment variables by default
- 7466945: Add support for Stop On Call, in order to trigger a restart of the instance.
  To enable it, set the `STOP_ON_CALL_ENABLED` environment variable to `true`.

## 0.5.3

### Patch Changes

- ec5cd7a: Add support for `auto` value for `QLEVER_GENERATE_CONFIG_FILE`

## 0.5.2

### Patch Changes

- d5e17da: Upgrade server base image to `latest@sha256:526b36fbdcbf0629c07060368b09d838b60759d8f50bf7eee70d496236a8d2cb`

## 0.5.1

### Patch Changes

- 7bb4128: Add support for multiple files

## 0.5.0

### Minor Changes

- d16eb8a: Add support for db persistence for the UI

## 0.4.0

### Minor Changes

- e1512c7: Permissions were updated to make sure that the server and the UI can run without any issue with any user ID.
  The persistent data is now stored in the `/data` directory.
  Make sure to update your deployments/stacks to use the new path.
  The default user is now `nobody` (UID: 65534).

## 0.3.1

### Patch Changes

- d4c9ed2: Upgrade `qlever` CLI to 0.5.12

## 0.3.0

### Minor Changes

- 861a0d3: Add support for petrimaps.

  To configure the button that redirects to the map view, just define the `MAP_VIEW_BASE_URL` environment variable for the UI container.
  The default value is `""`, which will not display any button to open the map view.

## 0.2.0

### Minor Changes

- 43fac9a: Check if the data needs to be downloaded and if the index needs to be computed.

### Patch Changes

- cbc49cf: Upgrade base image to `adfreiburg/qlever:latest@sha256:90c4b7646489e3ea39a9f683b513b966ef435cbf9be6ccfc6b4c88e9446e476b`

## 0.1.3

### Patch Changes

- 78540d7: Upgrade server to latest@sha256:921390670128231d772be55817b2ed79484989f3891b1318e5f568d96f2249ae

## 0.1.2

### Patch Changes

- 5605f07: Bump qlever server to commit-2ebca4d
- 752f237: Bump qlever cli to 0.5.8

## 0.1.1

### Patch Changes

- c1f3518: Upgrade Docker base images

## 0.1.0

### Minor Changes

- 5e31a9c: First release
