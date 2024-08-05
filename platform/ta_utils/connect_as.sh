#!/bin/bash

if [ $# -lt 1 ]; then
    echo Invalid argument:
    echo "./connect_as.sh <as_number>"
    echo "./connect_as.sh ixp <ixp_number>"
    exit 1
fi

WORKDIR=/home/ubuntu/mini_internet_project/platform/

if [ $1 == "ixp" ]; then
    docker exec -it ${2}_IXP vtysh
else
    docker exec -itw /root/ ${1}_ssh bash
fi