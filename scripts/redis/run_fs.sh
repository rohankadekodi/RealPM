#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: sudo ./run_fs.sh <fs> <run_id>"
    exit 1
fi

set -x

workload=redis
fs=$1
run_id=$2
src_dir=`readlink -f ../../`
cur_dir=`readlink -f ./`
redis_dir=$src_dir/redis
pmem_dir=/mnt/pmem_emul
boost_dir=$src_dir/splitfs
result_dir=$src_dir/results
fs_results=$result_dir/$fs/$workload

if [ "$fs" == "boost" ]; then
    run_boost=1
    mode=strict
elif [ "$fs" == "sync_boost" ]; then
    run_boost=1
    mode=sync
elif [ "$fs" == "posix_boost" ]; then
    run_boost=1
    mode=posix
else
    run_boost=0
fi

ulimit -c unlimited

echo Sleeping for 5 seconds . . 
sleep 5

run_workload()
{

    echo ----------------------- REDIS WORKLOAD ---------------------------

    mkdir -p $fs_results
    rm $fs_results/run$run_id

    rm -rf $pmem_dir/*

    if [ $run_boost -eq 1 ]; then
        export LD_LIBRARY_PATH=$src_dir/splitfs-so/redis/$mode
        export NVP_TREE_FILE=$boost_dir/bin/nvp_nvp.tree
    fi

    sleep 5

    date

    if [ $run_boost -eq 1 ]; then
        LD_PRELOAD=$src_dir/splitfs-so/redis/$mode/libnvp.so $redis_dir/src/redis-server $redis_dir/redis.conf &
    else
        $redis_dir/src/redis-server $redis_dir/redis.conf &
    fi

    sleep 2
    $redis_dir/src/redis-benchmark -t set -n 1000000 -d 1024 -c 1 -s /tmp/redis.sock 2>&1 | tee $fs_results/run$run_id

    date

    cd $current_dir

    echo Sleeping for 5 seconds . .
    sleep 5

}


run_workload

cd $cur_dir
