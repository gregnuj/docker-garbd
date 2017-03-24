#!/bin/bash -e

# Set 'DEBUG=1' environment variable to see detailed output for debugging
if [[ ! -z "$DEBUG" && "$DEBUG" != 0 && "${DEBUG^^}" != "FALSE" ]]; then
  set -x
fi

declare SERVICE_NAME="${SERVICE_NAME:=""}"

if [[ -z $SERVICE_NAME ]] ; then
    SERVICE_NAME=$(hostname -i | nslookup | awk -F'= ' 'NR==5 { print $2 }'| awk -F'.' '{print $1}')
fi

echo $SERVICE_NAME

