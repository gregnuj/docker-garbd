#!/bin/bash -e

# Set 'DEBUG=1' environment variable to see detailed output for debugging
if [[ ! -z "$DEBUG" && "$DEBUG" != 0 && "${DEBUG^^}" != "FALSE" ]]; then
  set -x
fi

declare SERVICE_HOSTNAME="${SERVICE_HOSTNAME:=""}"

SERVICE_HOSTNAME=$(hostname -i | nslookup | awk -F'= ' 'NR==5 { print $2 }'| awk -F'.' '{print $1 "." $2}')

echo $SERVICE_HOSTNAME

