#!/bin/bash -e

source swarm_common.sh
exec "/usr/bin/garbd" "-a" "$(cluster_address)" "-g" "$(cluster_name)"
