#!/bin/bash -e

# Set 'DEBUG=1' environment variable to see detailed output for debugging
if [[ ! -z "$DEBUG" && "$DEBUG" != 0 && "${DEBUG^^}" != "FALSE" ]]; then
  set -x
fi

declare SERVICE_INSTANCE="${SERVICE_INSTANCE:=""}"

if [[ -z $SERVICE_INSTANCE ]] ; then
    INTEGER=$(hostname -i | nslookup | awk -F'= ' 'NR==5 { print $2 }'| awk -F'.' '{print $2}')
    if [[ $INTEGER =~ ^-?[0-9]+$ ]]; then
        SERVICE_INSTANCE=$INTEGER
    fi
fi

echo $SERVICE_INSTANCE
