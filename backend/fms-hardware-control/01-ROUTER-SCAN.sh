#!/bin/sh

DIR=$(dirname "$0")

. $DIR/global.sh

__usage="
    This script scans the network for the presence of the EdgeRouter X.

    Usage: 01-ROUTER-SCAN.sh [ normal | factory ]

    Parameters:
        0th:
            - normal: This scans for the router, assuming it has undergone first time setup.
            - factory: This scans for the router, assuming it has factory default settings.

    Exit codes:
        0  - Success
        1  - Nonspecific runtime error
        11 - Could not ping router (either not plugged in or not at right ip)
        12 - Could not login to router (probably needs a hard reset if this happens)
    
    Requires:
        - sshpass
"

entrypoint() {
    if [ $# -ne 1 ] || [ $1 = "help" ]; then
        show_usage
    fi
    
    case "$1" in
        normal|factory)
            ;;
        *)
            show_usage "0th param can only be one of [normal, factory]"
            ;;
    esac

    # Ready to run

    # Store IPs
    if [ $1 = "factory" ]; then
        SRC_IP=$FMS_SETUP_IP
        DEST_IP=$ROUTER_FACTORY_IP
        ROUTER_USERNAME=$ROUTER_FACTORY_USERNAME
        ROUTER_PASSWORD=$ROUTER_FACTORY_PASSWORD
    else
        SRC_IP=$FMS_IP
        DEST_IP=$ROUTER_IP
        : ${ROUTER_PASSWORD:?"Router password not set"}
    fi

    # Ping expected IP
    ping_router $1
    PING_SUCCESS=$?
    if [ $PING_SUCCESS -ne 0 ]; then
        exit 11
    fi

    login_to_router
    LOGIN_SUCCESS=$?
    if [ $LOGIN_SUCCESS -ne 0 ]; then
        exit 12
    fi

}


ping_router() {
    echo "Pinging $DEST_IP from $SRC_IP"
    ping -c 1 -I $SRC_IP $DEST_IP > /dev/null
    PING_SUCCESS=$?
    if [ $PING_SUCCESS -ne 0 ]; then
        echo "Unable to find router at $DEST_IP"
    else
        echo "Found router at $DEST_IP"
    fi
    return $PING_SUCCESS
}

login_to_router() {
    echo "Logging into router as $ROUTER_USERNAME"
    sshpass -p $ROUTER_PASSWORD ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$ROUTER_USERNAME@$DEST_IP" whoami > /dev/null 2> /dev/null
    LOGIN_SUCCESS=$?
    if [ $LOGIN_SUCCESS -ne 0 ]; then
        echo "Unable to login to router as $ROUTER_USERNAME"
    else
        echo "Logged into router as $ROUTER_USERNAME"
    fi
    return $LOGIN_SUCCESS
}

entrypoint "$@"
exit $?