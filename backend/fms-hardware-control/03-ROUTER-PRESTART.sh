#!/bin/sh

DIR=$(dirname "$0")

. $DIR/global.sh

__usage="
    This performs the prestart actions for the EdgeRouter X.

    Usage: 03-ROUTER-PRESTART.sh RED1NUM RED2NUM RED3NUM BLUE1NUM BLUE2NUM BLUE3NUM

    Parameters:
        0th:-5th
            These are the team numbers that need to be setup

    Exit codes:
        0  - Success
        1  - Nonspecific runtime error
        11 - SSH Error (probably needs advanced troubleshooting if this happens)
    
    Requires:
        - sshpass
"

entrypoint() {
    if [ $# -ne 6 ] || [ $1 = "help" ]; then
        show_usage
    fi
    # Ready to run

    configure_router $1 $2 $3 $4 $5 $6
    SUCCESS=$?
    if [ $SUCCESS -ne 0 ]; then
        exit 11
    fi

}

# 6 Params - the team nums
configure_router() {
    COMMANDS=""

    STATION=0
    for NUM in "$@" 
    do
        NUM=`printf "%04d\n" $NUM`
        if [ $STATION -lt 3 ]; then
            STNAME="RED"`expr $STATION + 1`
            VLAN="1"`expr $STATION + 1`
        else
            STNAME="BLUE"`expr $STATION - 2`
            VLAN="2"`expr $STATION - 2`
        fi
        IP_FIRST=`echo $NUM | cut -c1-2`
        IP_SECOND=`echo $NUM | cut -c3-4`
        IP_MIDDLE=`printf %d $IP_FIRST`.`printf %d $IP_SECOND`
        COMMANDS=$COMMANDS"
            \$CW delete interfaces ethernet eth0 vif $VLAN
            \$CW set interfaces ethernet eth0 vif $VLAN address 10.$IP_MIDDLE.254/24
            \$CW delete service dhcp-server shared-network-name $STNAME
            \$CW set service dhcp-server shared-network-name $STNAME subnet 10.$IP_MIDDLE.0/24 start 10.$IP_MIDDLE.50 stop 10.$IP_MIDDLE.150
            \$CW set service dhcp-server shared-network-name $STNAME subnet 10.$IP_MIDDLE.0/24 default-router 10.$IP_MIDDLE.254
            \$CW set service dhcp-server shared-network-name $STNAME authoritative enable
        "

        STATION=`expr $STATION + 1`
    done

    echo "Logging into router as $ROUTER_USERNAME"
    sshpass -p $ROUTER_PASSWORD ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$ROUTER_USERNAME@$ROUTER_IP" > /dev/null 2> /dev/null <<- EOF
    CW=/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper
    \$CW begin
    $COMMANDS
    \$CW commit
    \$CW end
EOF
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