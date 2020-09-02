#!/bin/sh

DIR=$(dirname "$0")

. $DIR/global.sh

__usage="
    This script initializes an EdgeRouter X from factory settings

    Usage: 01A-ROUTER-INIT.sh [ normal | factory ]

    Parameters:
        0th:
            - normal: This sets up the router, assuming it has undergone first time setup.
            - factory: This sets up the router, assuming it has factory default settings.

    Exit codes:
        0  - Success
        1  - Nonspecific runtime error
        11 - SSH Error (probably needs advanced troubleshooting if this happens)
    
    Requires:
        - sshpass
"

entrypoint() {
    if [ $# -ne 1 ] || [ $1 = "help" ]; then
        show_usage
    fi

    DESIRED_PASSWORD=${ROUTER_PASSWORD:?"Router password not set"}

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
        DEST_IP=$ROUTER_FACTORY_IP
        ROUTER_USERNAME=$ROUTER_FACTORY_USERNAME
        ROUTER_PASSWORD=$ROUTER_FACTORY_PASSWORD
    else
        DEST_IP=$ROUTER_IP
    fi

    configure_router
    SUCCESS=$?
    if [ $SUCCESS -ne 0 ]; then
        exit 11
    fi

}

configure_router() {
    echo "Logging into router as $ROUTER_USERNAME"
    CONFIG=`cat $DIR/resources/init-config.boot`
    sshpass -p $ROUTER_PASSWORD ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$ROUTER_USERNAME@$DEST_IP" > /dev/null 2> /dev/null <<- EOFA 
    CW=/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper
    DESIRED_PASSWORD=$DESIRED_PASSWORD
    cat <<- EOFB > /config/config.boot
$CONFIG
EOFB
    \$CW begin
    \$CW load
    \$CW commit
    \$CW end
EOFA
    LOGIN_SUCCESS=$?
    if [ $LOGIN_SUCCESS -ne 0 ]; then
        echo "Unable to login to router as $ROUTER_USERNAME"
    else
        echo "Logged into router and committed changes as $ROUTER_USERNAME"
    fi
    return $LOGIN_SUCCESS
}

entrypoint "$@"
exit $?