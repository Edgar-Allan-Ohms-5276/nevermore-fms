#!/bin/sh

: ${ROUTER_USERNAME:="nevermore"}

ROUTER_IP="10.0.100.254"
ROUTER_FACTORY_IP="192.168.1.1"
ROUTER_FACTORY_USERNAME="ubnt"
ROUTER_FACTORY_PASSWORD="ubnt"
FMS_IP="10.0.100.5"
FMS_SETUP_IP="192.168.1.2"

# Param 0 - Optional message prefix
show_usage() {
        echo $1"$__usage"
        exit 1
}