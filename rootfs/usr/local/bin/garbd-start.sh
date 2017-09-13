#!/bin/bash -e

source galera_common.sh
exec "/usr/bin/garbd" "-a" "$(wsrep_cluster_address)" "-g" "$(wsrep_cluster_name)"
