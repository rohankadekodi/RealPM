#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: sudo ./run_fs.sh <fs> <run_id>"
    exit 1
fi

set -x

workload=worst
fs=$1
run_id=$2
cur_dir=`readlink -f ./`
src_dir=`readlink -f ../../`
worst_dir=$src_dir/worst
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

run_workload()
{

    echo ----------------------- worst WORKLOAD ---------------------------

    mkdir -p $fs_results
    rm $fs_results/run$run_id

    sleep 2

    date

    if [ $run_boost -eq 1 ]; then

        rm -rf $pmem_dir/*
        cp $workload_dir/test.txt $pmem_dir && sync
        sync && echo 3 > /proc/sys/vm/drop_caches
        export LD_LIBRARY_PATH=$src_dir/splitfs-so/worst/boost
        export NVP_TREE_FILE=$boost_dir/bin/nvp_nvp.tree
        LD_PRELOAD=$src_dir/splitfs-so/worst/boost/libnvp.so $worst_dir/worst 16K 1M 4K 100000 2>&1 | tee $fs_results/run$run_id

    else

        rm -rf $pmem_dir/*
        cp $workload_dir/test.txt $pmem_dir && sync
        sync && echo 3 > /proc/sys/vm/drop_caches
        export LD_LIBRARY_PATH=$src_dir/splitfs-so/worst/fs
        export NVP_TREE_FILE=$boost_dir/bin/nvp_nvp.tree
        LD_PRELOAD=$src_dir/splitfs-so/worst/fs/libnvp.so $worst_dir/worst 16K 1M 4K 100000 2>&1 | tee $fs_results/run$run_id

    fi

    date

}


run_workload

cd $cur_dir
