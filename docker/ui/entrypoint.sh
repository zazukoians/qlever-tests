#!/bin/sh

# Some configuration
QLEVER_UI_PORT="${QLEVER_UI_PORT:-7002}"
QLEVER_UI_WORKERS="${QLEVER_UI_WORKERS:-3}"
QLEVER_UI_LIMIT_REQUEST_LINE="${QLEVER_UI_LIMIT_REQUEST_LINE:-10000}"

# Make the script fail on errors
set -eux

# Configure the dataset
python manage.py configure default "${QLEVER_SERVER_ENDPOINT}"

# Start the UI
gunicorn \
  --bind ":${QLEVER_UI_PORT}" \
  --workers "${QLEVER_UI_WORKERS}" \
  --limit-request-line "${QLEVER_UI_LIMIT_REQUEST_LINE}" \
  qlever.wsgi:application
