# Redirect app

This Deno application is responsible for redirecting the user to the correct URL by updating the query parameters.
It is used in the Docker Compose stack to rewrite the `backend` URL to the internal URL of the QLever server so that Petrimaps can access the QLever server.

## Usage

To start the redirect app, you can use the following command:

```sh
docker build -t redirect .
docker run --rm -p 7003:7003 -it redirect
```

## Environment variables

- `PUBLIC_MAPS_URL`: The public URL of the maps service. Default is `http://localhost:7004`.
- `PUBLIC_BACKEND_URL`: The public URL of the backend service. Default is `http://localhost:7001`.
- `PRIVATE_BACKEND_URL`: The private URL of the backend service. Default is `http://server-local:7001`.
