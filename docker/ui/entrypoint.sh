#!/bin/sh

set -eu

# Generate Qleverfile
/home/qlever/scripts/generate-qleverfile.sh

# Go to the data directory
cd /home/qlever/data

QLEVER_FILE_PATH="${QLEVER_FILE_PATH:-/home/qlever/data/Qleverfile}"

# Check if the Qleverfile exists
if [ ! -f "${QLEVER_FILE_PATH}" ]; then
  echo "ERROR: Qleverfile not found at '${QLEVER_FILE_PATH}'"
  exit 1
fi

# Display the Qleverfile
echo "INFO: Qleverfile found at '${QLEVER_FILE_PATH}'"
cat "${QLEVER_FILE_PATH}"

# Using `qlever` command is not working…
# # Start the QLever UI
# qlever ui
#
# # Keep the container running
# sleep infinity

# Use the following as a workaround for now

cd /app

# Some configuration
QLEVER_SERVER_ENDPOINT="${QLEVER_SERVER_ENDPOINT:-http://localhost:7001}"
QLEVER_UI_UI_PORT="${QLEVER_UI_UI_PORT:-7002}"
QLEVER_UI_WORKERS="${QLEVER_UI_WORKERS:-3}"
QLEVER_UI_LIMIT_REQUEST_LINE="${QLEVER_UI_LIMIT_REQUEST_LINE:-10000}"

# Configure the dataset
python manage.py configure default "${QLEVER_SERVER_ENDPOINT}"

# Start the UI
gunicorn \
  --bind ":${QLEVER_UI_UI_PORT}" \
  --workers "${QLEVER_UI_WORKERS}" \
  --limit-request-line "${QLEVER_UI_LIMIT_REQUEST_LINE}" \
  qlever.wsgi:application
