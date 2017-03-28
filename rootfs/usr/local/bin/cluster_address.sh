#!/bin/bash -e

# Set 'DEBUG=1' environment variable to see detailed output for debugging
if [[ ! -z "$DEBUG" && "$DEBUG" != 0 && "${DEBUG^^}" != "FALSE" ]]; then
  set -x
fi

source docker_info.sh

declare SERVICE_NAME="${SERVICE_NAME:="$(service_name)"}"
declare SERVICE_INSTANCE="${SERVICE_INSTANCE:="$(service_instance)"}"
declare NODE_ADDRESS="${NODE_ADDRESS:="$(node_address)"}"
declare CLUSTER_MEMBERS="${CLUSTER_MEMBERS:=""}"
declare CLUSTER_ADDRESS="${CLUSTER_ADDRESS:=""}"
declare CLUSTER_MINIMUM="${CLUSTER_MINIMUM:="2"}"

if [[ ! -z "$CLUSTER_ADDRESS" ]]; then
    ## may need to parse out members
    CLUSTER_MINIMUM=$(echo "$CLUSTER_ADDRESS" | tr ',' "\n" | sort -u | grep -v -e '^$' | wc -l)
elif [[ ! -z "$CLUSTER_MEMBERS" ]]; then
    CLUSTER_MINIMUM=$(echo "$CLUSTER_ADDRESS" | tr ',' "\n" | sort -u | grep -v -e '^$' | wc -l)
fi

# It is possible that containers on other nodes aren't running yet and should be waited on
# before trying to start. For example, this occurs when updated container images are being pulled
# by `docker service update <service>` or on a full cluster power loss
while [[ -z "$CLUSTER_ADDRESS" ]]; do
    CLUSTER_MEMBERS="$(getent hosts tasks.${SERVICE_NAME} | awk -v ORS=',' '{print $1}')"
    COUNT=$(echo CLUSTER_MEMBERS | tr ',' ' ' | wc -w)
    if [[ $COUNT -lt $(($CLUSTER_MINIMUM)) ]]; then
        echo "Waiting for at least $CLUSTER_MINIMUM IP addresses to resolve..." >&2
        SLEEPS=$((SLEEPS + 1))
        sleep 3
    elif [[ "${NODE_ADDDRESS}" == "${CLUSTER_MEMBERS%,*}" ]]; then
        CLUSTER_ADDRESS="gcomm://"
    else
        CLUSTER_MEMBERS="${CLUSTER_MEMBERS%%,}" # strip trailing commas
        CLUSTER_ADDRESS="gcomm://$CLUSTER_MEMBERS?pc.wait_prim=no"
    fi

    # After 90 seconds reduce CLUSTER_ADDRESS_MINIMUM
    if [[ $SLEEPS -ge 30 ]]; then
        SLEEPS=0
        CLUSTER_MINIMUM=$((CLUSTER_MINIMUM - 1))
        echo "Reducing CLUSTER_MINIMUM to $CLUSTER_MINIMUM" >&2
    fi
done

echo "Cluster address set to $CLUSTER_ADDRESS" >&2
echo $CLUSTER_ADDRESS

