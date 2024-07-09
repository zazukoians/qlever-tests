#!/bin/bash

# Some configuration
QLEVER_UI_PORT="${QLEVER_UI_PORT:-7002}"
QLEVER_UI_WORKERS="${QLEVER_UI_WORKERS:-3}"
QLEVER_UI_LIMIT_REQUEST_LINE="${QLEVER_UI_LIMIT_REQUEST_LINE:-10000}"

# Allow the script to use jobs (`m` flag)
set -euxm

# Start the UI in the background
gunicorn \
  --bind ":${QLEVER_UI_PORT}" \
  --workers "${QLEVER_UI_WORKERS}" \
  --limit-request-line "${QLEVER_UI_LIMIT_REQUEST_LINE}" \
  qlever.wsgi:application &

# Configure the dataset
python manage.py configure default "${QLEVER_SERVER_ENDPOINT}"

# Put the UI process in the foreground to keep the container running
fg %1
