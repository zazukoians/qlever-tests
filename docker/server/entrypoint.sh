#!/bin/bash

# Tweak indexing
SHOULD_INDEX="${SHOULD_INDEX:-false}"
FORCE_INDEXING="${FORCE_INDEXING:-false}"

# Tweak data download
SHOULD_DOWNLOAD="${SHOULD_DOWNLOAD:-true}"
FORCE_DOWNLOAD="${FORCE_DOWNLOAD:-false}"

set -eu

# Display some debug information
echo "INFO: Indexing : should index = ${SHOULD_INDEX} ; force indexing = ${FORCE_INDEXING}"
echo "INFO: Data download : should download = ${SHOULD_DOWNLOAD} ; force download = ${FORCE_DOWNLOAD}"

# Generate Qleverfile
/qlever/scripts/generate-qleverfile.sh

# Go to the data directory
cd /data

QLEVER_FILE_PATH="${QLEVER_FILE_PATH:-/data/Qleverfile}"

# Check if the Qleverfile exists
if [ ! -f "${QLEVER_FILE_PATH}" ]; then
  echo "ERROR: Qleverfile not found at '${QLEVER_FILE_PATH}'"
  exit 1
fi

# Display the Qleverfile
echo "INFO: Qleverfile found at '${QLEVER_FILE_PATH}'"
cat "${QLEVER_FILE_PATH}"

INPUT_FILES=$(grep "^INPUT_FILES[[:space:]]*=" "${QLEVER_FILE_PATH}" | head -n1 | sed 's/.*=[[:space:]]*//')
HAS_INPUT_FILES=$(echo "${INPUT_FILES}" | sed '/^[[:space:]]*$/d' | wc -l)

if [ "${HAS_INPUT_FILES}" -ne 0 ]; then
  echo "INFO: Found 'INPUT_FILES' in the Qleverfile"

  # Check if the input files already exist
  if [ -f "${INPUT_FILES}" ]; then
    echo "INFO: Input files found at '${INPUT_FILES}'"
    SHOULD_DOWNLOAD="false" # As the input files are already present, no need to download them
  else
    echo "INFO: Input files not found at '${INPUT_FILES}'"

    # Display the info in the logs only if the download is enabled
    if [ "${SHOULD_DOWNLOAD}" = "true" ]; then
      echo "INFO: Trigger download of input files…"
    fi
  fi
fi

# If the download of the input files is forced, then download them in all cases
if [ "${FORCE_DOWNLOAD}" = "true" ]; then
  echo "INFO: Forcing download of input files…"
  SHOULD_DOWNLOAD="true"
fi

# Check if there is a line that starts with `GET_DATA_CMD` in the Qleverfile
if grep -q "^GET_DATA_CMD" "${QLEVER_FILE_PATH}"; then
  echo "INFO: Found 'GET_DATA_CMD' in the Qleverfile"
  if [ "${SHOULD_DOWNLOAD}" = "true" ]; then
    echo "INFO: Trigger download of data…"
    qlever get-data
    SHOULD_INDEX="true" # As the data is downloaded, we should index it
  else
    echo "INFO: Skipping download of data…"
  fi
fi

if [ "${SHOULD_INDEX}" = "true" ]; then
  echo "INFO: Indexing is enabled"
  qlever index
elif [ "${FORCE_INDEXING}" = "true" ]; then
  echo "INFO: Forcing indexing"
  qlever index
else
  echo "INFO: Indexing is disabled"
fi

qlever start

# Keep the container running
sleep infinity
