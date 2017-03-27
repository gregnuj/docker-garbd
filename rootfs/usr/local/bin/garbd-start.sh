!#/bin/bash

declare SERVICE_NAME="${SERVICE_NAME:="$(service_name.sh)"}"
declare CLUSTER_ADDRESS="${CLUSTER_ADDRESS:="$(cluster_address.sh)"}"

exec /usr/bin/garbd -a $CLUSTER_ADDRESS -g ${SERVICE_NAME}-cluster
