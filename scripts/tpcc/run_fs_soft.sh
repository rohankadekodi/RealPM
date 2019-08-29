#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: sudo ./run_fs.sh <fs> <run_id>"
    exit 1
fi

set -x

workload=tpcc
fs=$1
run_id=$2
cur_dir=`readlink -f ./`
src_dir=`readlink -f ../../`
tpcc_dir=$src_dir/tpcc-sqlite
workload_dir=$tpcc_dir/database
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

    echo ----------------------- TPCC WORKLOAD ---------------------------

    mkdir -p $fs_results
    rm $fs_results/run$run_id

    rm -rf $pmem_dir/*
    cp $workload_dir/tpcc.db $pmem_dir && sync

    if [ $run_boost -eq 1 ]; then
        export LD_LIBRARY_PATH=$src_dir/splitfs-so/tpcc/$mode/soft
        export NVP_TREE_FILE=$boost_dir/bin/nvp_nvp.tree
    else
        export LD_LIBRARY_PATH=$src_dir/splitfs-so/fs
        export NVP_TREE_FILE=$boost_dir/bin/nvp_nvp.tree
    fi

    sleep 5

    date

    if [ $run_boost -eq 1 ]; then
        time LD_PRELOAD=$src_dir/splitfs-so/tpcc/$mode/soft/libnvp.so $tpcc_dir/tpcc_start -w 4 -c 1 -t 200000 2>&1 | tee $fs_results/run_soft_over_$run_id
    else
        time LD_PRELOAD=$src_dir/splitfs-so/fs/libnvp.so $tpcc_dir/tpcc_start -w 4 -c 1 -t 200000 2>&1 | tee $fs_results/run_soft_over_$run_id
    fi

    date

    echo Sleeping for 5 seconds . .
    sleep 5

}


run_workload

cd $cur_dir
