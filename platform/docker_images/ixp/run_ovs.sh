#!/bin/bash

set -e

command=/usr/share/openvswitch/scripts/ovs-ctl
status_interval="${OVS_STATUS_INTERVAL:-5}"

function stop() {
    $command stop
    exit 0
}

function restart() {
    $command restart
}

trap "stop" SIGINT SIGTERM
trap "restart" SIGHUP

# Launch ovs daemons
$command start
sleep 2

ovs-vsctl add-br IXP
ovs-ofctl add-flow IXP action=NORMAL

# Loop while the daemons are alive.
# status returns exit code 0 only if all daemons are are running.
while $command status > /dev/null ; do
    sleep "${status_interval}"
done

$command status

exit 1 # exit unexpected
