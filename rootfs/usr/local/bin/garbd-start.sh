#!/bin/bash -e

source cluster_common.sh
exec "/usr/bin/garbd" "-a" "$(cluster_address)" "-g" "$(cluster_name)"
