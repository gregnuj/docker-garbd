#!/bin/bash -e

# Set 'DEBUG=1' environment variable to see detailed output for debugging
if [[ ! -z "$DEBUG" && "$DEBUG" != 0 && "${DEBUG^^}" != "FALSE" ]]; then
  set -x
fi

declare SERVICE_NAME="${SERVICE_NAME:="$(service_name.sh)"}"
declare CONTAINER_NAME="${CONTAINER_NAME:="${SERVICE_NAME##*_}"}"

echo $CONTAINER_NAME

