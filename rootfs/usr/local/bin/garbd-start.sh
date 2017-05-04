#!/bin/bash -e

source cluster_common.sh
declare SERVICE_NAME="$(service_name)"
declare CLUSTER_MEMBERS="$(cluster_members)"

exec "/usr/bin/garbd" "-a" "gcomm://${CLUSTER_MEMBERS}" "-g" "${SERVICE_NAME}-cluster"
