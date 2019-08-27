#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Illegal number of parameters; Please provide <dax/ledger> as the parameter;"
    exit 1
fi

set -x

system=$1

sudo rm -rf /mnt/pmem_emul/* && sync

if [ "$system" = "ledger" ]; then    
    sudo /home/rohan/projects/quill-modified/run_quill.sh -p /home/rohan/projects/quill-modified/ -t nvp_nvp.tree ./redis-server ../redis.conf &
else
    sudo ./redis-server ../redis.conf &
fi

sleep 1

sudo ./redis-benchmark -t set -n 1000000 -d 1024 -c 1 -s /tmp/redis.sock

sudo -S kill `pgrep redis`
#sudo kill `pgrep sudo`
