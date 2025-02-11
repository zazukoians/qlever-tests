#!/bin/bash

# Instane tweaks
SHOW_LOGS="${SHOW_LOGS:-true}"

# Tweak indexing
SHOULD_INDEX="${SHOULD_INDEX:-false}"
FORCE_INDEXING="${FORCE_INDEXING:-false}"

# Tweak data download
SHOULD_DOWNLOAD="${SHOULD_DOWNLOAD:-true}"
FORCE_DOWNLOAD="${FORCE_DOWNLOAD:-false}"

# Tweak failures
START_ERROR_FILE_PATH="${START_ERROR_FILE_PATH:-/qlever/start_error}"
START_PIPE_FILE="${START_PIPE_FILE:-/qlever/pipe_start}"
START_STOP_ON_ERROR="${START_STOP_ON_ERROR:-true}"

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

# Remove the pipe file and the error file if they exist
rm -f "${START_PIPE_FILE}" "${START_ERROR_FILE_PATH}"
mkfifo "${START_PIPE_FILE}" # Create a named pipe (FIFO)

# Run the command inside a subshell and monitor its output
# This is useful to detect errors and kill the process if needed, to avoid being stuck
(
  # Start the command and capture its PID
  qlever start > "${START_PIPE_FILE}" 2>&1 &
  CMD_PID=$!

  # Get the logs and check for errors
  # If an error is detected, kill the process to avoid being stuck
  while IFS= read -r line; do
    echo "(qlever start) ${line}"
    case "$line" in
      *ERROR*)
        echo "Error detected!"
        touch "${START_ERROR_FILE_PATH}" # Mark that an error occurred
        kill -9 "${CMD_PID}" # Kill the process
        break
        ;;
    esac
  done < "${START_PIPE_FILE}"
)

# Check if an error was detected during the start process
if [ -f "${START_ERROR_FILE_PATH}" ]; then
  if [ "${START_STOP_ON_ERROR}" = "true" ]; then
    echo "ERROR: An error occurred during the start process."
    exit 1
  fi
  echo "INFO: An error occurred during the start process."
fi

# Keep the container running
if [ "${STOP_ON_CALL_ENABLED}" = "true" ]; then
  if [ "${SHOW_LOGS}" = "true" ]; then
    echo "INFO: Showing logs..."
    qlever log &
  fi

  # This would expose another HTTP endpoint (by default on port 8080) to stop the container ; this can be useful to force a restart
  echo "Starting stop-on-call server..."
  stop_on_call
else
  if [ "${SHOW_LOGS}" = "true" ]; then
    echo "INFO: Showing logs..."
    qlever log
  else
    echo "Sleeping indefinitely..."
    sleep infinity
  fi
fi
