#!/bin/sh

set -eu

##################################################################################
# This script generates a Qleverfile that can be used to start a QLever instance #
##################################################################################

QLEVER_FILE_PATH="${QLEVER_FILE_PATH:-/data/Qleverfile}"

# Have a way to opt-out of generating the Qleverfile
QLEVER_GENERATE_CONFIG_FILE="${QLEVER_GENERATE_CONFIG_FILE:-true}"
if [ "${QLEVER_GENERATE_CONFIG_FILE}" = "auto" ]; then
  # Check if the Qleverfile already exists
  if [ -f "${QLEVER_FILE_PATH}" ]; then
    echo "INFO: Skipping Qleverfile generation, as 'QLEVER_GENERATE_CONFIG_FILE' is set to 'auto' and the file already exists at '${QLEVER_FILE_PATH}'"
    exit 0
  else
    echo "INFO: Generating Qleverfile, as 'QLEVER_GENERATE_CONFIG_FILE' is set to 'auto' and the file does not exist at '${QLEVER_FILE_PATH}'"
    QLEVER_GENERATE_CONFIG_FILE="true"
  fi
fi

if [ "${QLEVER_GENERATE_CONFIG_FILE}" != "true" ]; then
  echo "INFO: Skipping Qleverfile generation, as 'QLEVER_GENERATE_CONFIG_FILE' is not set to 'true'"
  exit 0
fi

dirname "${QLEVER_FILE_PATH}" | xargs mkdir -p

# Set default values for some configuration fields (could be overridden by other environment variables)
export QLEVER_DATA_NAME="${QLEVER_DATA_NAME:-default}"
export QLEVER_DATA_DESCRIPTION="${QLEVER_DATA_DESCRIPTION:-Default dataset}"

export QLEVER_INDEX_SETTINGS_JSON="${QLEVER_INDEX_SETTINGS_JSON:-{ \"ascii-prefixes-only\": false, \"num-triples-per-batch\": 100000 }}"

export QLEVER_SERVER_ACCESS_TOKEN="${QLEVER_SERVER_ACCESS_TOKEN:-${QLEVER_DATA_NAME}_7643543846_Zs6nw7yi3Z9m}"
export QLEVER_SERVER_HOST_NAME="${QLEVER_SERVER_HOST_NAME:-127.0.0.1}"
export QLEVER_SERVER_PORT="${QLEVER_SERVER_PORT:-7001}"
export QLEVER_SERVER_MEMORY_FOR_QUERIES="${QLEVER_SERVER_MEMORY_FOR_QUERIES:-5G}"
export QLEVER_SERVER_CACHE_MAX_SIZE="${QLEVER_SERVER_CACHE_MAX_SIZE:-2G}"
export QLEVER_SERVER_TIMEOUT="${QLEVER_SERVER_TIMEOUT:-30s}"

export QLEVER_RUNTIME_SYSTEM="${QLEVER_RUNTIME_SYSTEM:-native}"

export QLEVER_UI_UI_CONFIG="${QLEVER_UI_UI_CONFIG:-default}"
export QLEVER_UI_UI_PORT="${QLEVER_UI_UI_PORT:-7002}"

# Extract all environment variables that start with 'QLEVER_', as we ignore all other variables
QLEVER_ENV_VARS="$(env | grep '^QLEVER_' | sort -u)"

# Generate a specific section for the Qleverfile
generate_config_section () {
  local section="$1"
  local section_upper="$(echo "${section}" | tr '[:lower:]' '[:upper:]')"

  # Extract all environment variables for the given section
  local section_env_vars="$(echo "${QLEVER_ENV_VARS}" | grep "^QLEVER_${section_upper}_" | sed "s/^QLEVER_${section_upper}_//")"

  # Skip empty sections
  if [ -z "$section_env_vars" ]; then
    return
  fi

  echo "[$section]"
  echo "${section_env_vars}"
  echo ""
}

# Generate the Qleverfile, with the different sections
{
  echo "# Qleverfile auto-generated using environment variables at $(date), while starting the container"
  echo ""

  generate_config_section "data"
  generate_config_section "index"
  generate_config_section "server"
  generate_config_section "runtime"
  generate_config_section "ui"
} > "${QLEVER_FILE_PATH}" || exit 1

echo "INFO: Generated Qleverfile at '${QLEVER_FILE_PATH}'"

exit 0
