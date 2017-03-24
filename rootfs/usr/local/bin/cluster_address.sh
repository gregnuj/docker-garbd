#!/bin/bash -e

# Set 'DEBUG=1' environment variable to see detailed output for debugging
if [[ ! -z "$DEBUG" && "$DEBUG" != 0 && "${DEBUG^^}" != "FALSE" ]]; then
  set -x
fi

declare SERVICE_NAME="${SERVICE_NAME:="$(service_name.sh)"}"
declare SERVICE_INSTANCE="${SERVICE_INSTANCE:="$(service_instance.sh)"}"
declare NODE_ADDRESS="${NODE_ADDRESS:="$(node_address.sh)"}"
declare CLUSTER_MINIMUM="${CLUSTER_MINIMUM:="2"}"
declare CLUSTER_MEMBERS="${CLUSTER_MEMBERS:=""}"
declare CLUSTER_ADDRESS="${CLUSTER_ADDRESS:=""}"
declare DOCKER_HOST="${DOCKER_HOST:=""}"
declare SEED_NODE="${SEED_NODE:=""}"
declare SEED_NAME="${SEED_NAME:="${SERVICE_NAME/_data/_seed}"}"

if [[ ! -z "$SEED_NODE" ]]; then
    CLUSTER_ADDRESS="gcomm://"
elif [[ ! -z "$CLUSTER_ADDRESS" ]]; then
    ## may need to parse out members
    CLUSTER_MINIMUM=$(echo "$CLUSTER_ADDRESS" | tr ',' "\n" | sort -u | grep -v -e '^$' | wc -l)
elif [[ ! -z "$CLUSTER_MEMBERS" ]]; then
    CLUSTER_ADDRESS="gcomm://$CLUSTER_MEMBERS?pc.wait_prim=no"
    CLUSTER_MINIMUM=$(echo "$CLUSTER_ADDRESS" | tr ',' "\n" | sort -u | grep -v -e '^$' | wc -l)
fi

# It is possible that containers on other nodes aren't running yet and should be waited on
# before trying to start. For example, this occurs when updated container images are being pulled
# by `docker service update <service>` or on a full cluster power loss
while [[ -z "$CLUSTER_ADDRESS" ]]; do
    SEED_MEMBERS="$(getent hosts tasks.$SEED_NAME | awk -v ORS=',' '{print $1}')"
    SERVICE_MEMBERS="$(getent hosts tasks.$SERVICE_NAME | awk -v ORS=',' '{print $1}')"
    CLUSTER_MEMBERS="${SEED_MEMBERS}${SERVICE_MEMBERS}"
    COUNT=$(echo CLUSTER_MEMBERS | wc -l)
    if [[ $COUNT -lt $(($CLUSTER_MINIMUM)) ]]; then
        echo "Waiting for at least $CLUSTER_MINIMUM IP addresses to resolve..." >&2
        SLEEPS=$((SLEEPS + 1))
        sleep 3
    else
        CLUSTER_MEMBERS="${CLUSTER_MEMBERS%%,}"                        # strip trailing commas
        CLUSTER_ADDRESS="gcomm://$CLUSTER_MEMBERS"
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
