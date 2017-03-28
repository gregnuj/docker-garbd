!#/bin/bash

source docker_info.sh
declare SERVICE_NAME="${SERVICE_NAME:="$(service_name)"}"
declare CLUSTER_ADDRESS="${CLUSTER_ADDRESS:="$(cluster_address)"}"

exec /usr/bin/garbd -a $CLUSTER_ADDRESS -g ${SERVICE_NAME}-cluster
