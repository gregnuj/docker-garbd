#!/bin/bash -e

# Set 'DEBUG=1' environment variable to see detailed output for debugging
if [[ ! -z "$DEBUG" && "$DEBUG" != 0 && "${DEBUG^^}" != "FALSE" ]]; then
  set -x
fi

# Resolve node address
#
if [ -z "$NODE_ADDRESS" ]; then
	# Support Weave/Kontena
	NODE_ADDRESS=$(ip addr | awk '/inet/ && /ethwe/{sub(/\/.*$/,"",$2); print $2}')
fi
if [ -z "$NODE_ADDRESS" ]; then
	# Support Docker Swarm Mode
	NODE_ADDRESS=$(ip addr | awk '/inet/ && /eth0/{sub(/\/.*$/,"",$2); print $2}' | head -n 1)
elif [[ "$NODE_ADDRESS" =~ [a-zA-Z][a-zA-Z0-9:]+ ]]; then
	# Support interface - e.g. Docker Swarm Mode uses eth0
	NODE_ADDRESS=$(ip addr | awk "/inet/ && / $NODE_ADDRESS\$/{sub(/\\/.*$/,\"\",\$2); print \$2}" | head -n 1)
elif ! [[ "$NODE_ADDRESS" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
	# Support grep pattern. E.g. ^10.0.1.*
	NODE_ADDRESS=$(getent hosts $(hostname) | grep -e "$NODE_ADDRESS")
fi
if ! [[ "$NODE_ADDRESS" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
	echo "Could not determine NODE_ADDRESS: $NODE_ADDRESS" >&2
	exit 1
fi

echo $NODE_ADDRESS
