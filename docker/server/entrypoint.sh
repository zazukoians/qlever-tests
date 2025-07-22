#!/bin/bash

# Tweak indexing
SHOULD_INDEX="${SHOULD_INDEX:-false}"
FORCE_INDEXING="${FORCE_INDEXING:-false}"

# Tweak data download
SHOULD_DOWNLOAD="${SHOULD_DOWNLOAD:-true}"
FORCE_DOWNLOAD="${FORCE_DOWNLOAD:-false}"

# Additional parameters
START_ADDITIONAL_ARGS="${START_ADDITIONAL_ARGS:-}"

set -euo pipefail

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
  HAS_MISSING_INPUT_FILES="false"
  for INPUT_FILE in ${INPUT_FILES}; do
    if [ -f "${INPUT_FILE}" ]; then
      echo "INFO: Input file found at '${INPUT_FILE}'"
    else
      echo "INFO: Input file not found at '${INPUT_FILE}'"
      HAS_MISSING_INPUT_FILES="true"
    fi
  done

  # If all files are present, skip the download
  if [ "${HAS_MISSING_INPUT_FILES}" = "false" ]; then
    SHOULD_DOWNLOAD="false" # As the input files are already present, no need to download them
  fi

  # Display the info in the logs only if the download is enabled
  if [ "${SHOULD_DOWNLOAD}" = "true" ]; then
    echo "INFO: Trigger download of input files…"
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
  qlever index --overwrite-existing
elif [ "${FORCE_INDEXING}" = "true" ]; then
  echo "INFO: Forcing indexing"
  qlever index --overwrite-existing
else
  echo "INFO: Indexing is disabled"
fi

# Start the QLever server
echo "INFO: Starting Qlever server..."
if [ "${STOP_ON_CALL_ENABLED}" = "true" ]; then

  # Start QLever in the background
  qlever start --run-in-foreground $START_ADDITIONAL_ARGS &
  QLEVER_PID=$!

  # Start stop_on_call in the background
  stop_on_call &
  STOP_ON_CALL_PID=$!

  # Wait for either QLever or stop_on_call to exit
  wait -n $QLEVER_PID $STOP_ON_CALL_PID
  EXITED_PID=$?

  # Check which one exited
  if ! kill -0 $QLEVER_PID 2>/dev/null; then
    # QLever exited
    wait $QLEVER_PID
    QLEVER_EXIT_CODE=$?
    echo "qlever exited with code $QLEVER_EXIT_CODE"
    kill $STOP_ON_CALL_PID 2>/dev/null
    exit $QLEVER_EXIT_CODE
  else
    # stop_on_call was called, so we stop QLever
    echo ""
    echo ""
    echo ""
    echo "[INFO] Stopped using stop_on_call"
    qlever stop

    # Stop QLever manually, in case it is still running (it should not be, but just in case)
    kill $QLEVER_PID 2>/dev/null || true
    wait $QLEVER_PID || true
    exit 0
  fi

else
  qlever start --run-in-foreground $START_ADDITIONAL_ARGS
fi
