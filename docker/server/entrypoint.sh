#!/bin/bash

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

# Check if there is a line that starts with `GET_DATA_CMD` in the Qleverfile
if grep -q "^GET_DATA_CMD" "${QLEVER_FILE_PATH}"; then
  echo "INFO: Found 'GET_DATA_CMD' in the Qleverfile, executing it"
  qlever get-data
fi

qlever index
qlever start

# Keep the container running
sleep infinity
