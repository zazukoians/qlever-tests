#!/bin/bash

set -eux

# Some configuration
QLEVER_ACCESS_TOKEN="10aWWjuk1dhYfTir"
QLEVER_ACCESS_TOKEN="dataset_7643543846_Zs6nw7yi3Z9m"
QLEVER_DATASET_JSON_SETTINGS='{ "ascii-prefixes-only": false, "num-triples-per-batch": 100000 }'
QLEVER_DATASET_DATA_PATH="${QLEVER_DATASET_DATA_PATH:-"/custom/data.nt"}"
QLEVER_DATASET_SOURCE_KIND="${QLEVER_DATASET_SOURCE:-"file"}"
QLEVER_DATASET_SOURCE_LOCATION="${QLEVER_DATASET_SOURCE_LOCATION:-"/custom/data.nt"}"

# Fetch the data file
if [ "${QLEVER_DATASET_SOURCE_KIND}" = "file" ]; then
  # Copy the data file to the expected location
  if [ "${QLEVER_DATASET_SOURCE_LOCATION}" = "${QLEVER_DATASET_DATA_PATH}" ]; then
    echo "INFO: Source and destination are the same, skipping copy"
  else
    if [ ! -f "${QLEVER_DATASET_SOURCE_LOCATION}" ]; then
      echo "ERROR: Source file not found: '${QLEVER_DATASET_SOURCE_LOCATION}'"
      exit 1
    fi
    cp "${QLEVER_DATASET_SOURCE_LOCATION}" "${QLEVER_DATASET_DATA_PATH}"
  fi
elif [ "${QLEVER_DATASET_SOURCE_KIND}" = "url" ]; then
  # Download the data file to the expected location
  curl -L "${QLEVER_DATASET_SOURCE_LOCATION}" -o "${QLEVER_DATASET_DATA_PATH}"
else
  echo "ERROR: Unknown source kind: '${QLEVER_DATASET_SOURCE_KIND}' (valid values are: file, url)"
  exit 1
fi

# Generate settings file
echo "${QLEVER_DATASET_JSON_SETTINGS}" > dataset.settings.json

# Create index
cat "${QLEVER_DATASET_DATA_PATH}" \
  | IndexBuilderMain \
      -F ttl \
      -f - \
      -i dataset \
      -s dataset.settings.json \
      --stxxl-memory 5G

# Start server
ServerMain \
  -i dataset \
  -j 8 \
  -p 7001 \
  -m 5G \
  -c 2G \
  -e 1G \
  -k 200 \
  -s 30s \
  -a "${QLEVER_ACCESS_TOKEN}"
