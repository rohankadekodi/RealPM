#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: sudo ./run_fs.sh <fs> <run_id>"
    exit 1
fi

set -x

workload=micro
fs=$1
run_id=$2
cur_dir=`readlink -f ./`
src_dir=`readlink -f ../../`
micro_dir=$src_dir/micro
workload_dir=$micro_dir/workload
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

    echo ----------------------- MICRO WORKLOAD ---------------------------

    mkdir -p $fs_results
    rm $fs_results/run$run_id

    if [ $run_boost -eq 1 ]; then
        export LD_LIBRARY_PATH=$src_dir/splitfs-so/micro/$mode
        export NVP_TREE_FILE=$boost_dir/bin/nvp_nvp.tree
    fi

    sleep 2

    date

    if [ $run_boost -eq 1 ]; then

        rm -rf $pmem_dir/*
        cp $workload_dir/test.txt $pmem_dir && sync
        sync && echo 3 > /proc/sys/vm/drop_caches
        LD_PRELOAD=$src_dir/splitfs-so/micro/$mode/libnvp.so $micro_dir/rw_expt write seq 4096 2>&1 | tee $fs_results/run$run_id

        rm $pmem_dir/*
        cp $workload_dir/test.txt $pmem_dir && sync
        sync && echo 3 > /proc/sys/vm/drop_caches
        LD_PRELOAD=$src_dir/splitfs-so/micro/$mode/libnvp.so $micro_dir/rw_expt write rand 4096 2>&1 | tee -a $fs_results/run$run_id

        rm $pmem_dir/*
        cp $workload_dir/test.txt $pmem_dir && sync
        sync && echo 3 > /proc/sys/vm/drop_caches
        LD_PRELOAD=$src_dir/splitfs-so/micro/$mode/libnvp.so $micro_dir/rw_expt read seq 4096 2>&1 | tee -a $fs_results/run$run_id

        rm $pmem_dir/*
        cp $workload_dir/test.txt $pmem_dir && sync
        sync && echo 3 > /proc/sys/vm/drop_caches
        LD_PRELOAD=$src_dir/splitfs-so/micro/$mode/libnvp.so $micro_dir/rw_expt read rand 4096 2>&1 | tee -a $fs_results/run$run_id

        rm $pmem_dir/*
        sync && echo 3 > /proc/sys/vm/drop_caches
        LD_PRELOAD=$src_dir/splitfs-so/micro/$mode/libnvp.so $micro_dir/rw_expt write seq 4096 2>&1 | tee -a $fs_results/run$run_id

    else

        rm -rf $pmem_dir/*
        cp $workload_dir/test.txt $pmem_dir && sync
        sync && echo 3 > /proc/sys/vm/drop_caches
        $micro_dir/rw_expt write seq 4096 2>&1 | tee $fs_results/run$run_id

        rm -rf $pmem_dir/*
        cp $workload_dir/test.txt $pmem_dir && sync
        sync && echo 3 > /proc/sys/vm/drop_caches
        $micro_dir/rw_expt write rand 4096 2>&1 | tee -a $fs_results/run$run_id

        rm -rf $pmem_dir/*
        cp $workload_dir/test.txt $pmem_dir && sync
        sync && echo 3 > /proc/sys/vm/drop_caches
        $micro_dir/rw_expt read seq 4096 2>&1 | tee -a $fs_results/run$run_id

        rm -rf $pmem_dir/*
        cp $workload_dir/test.txt $pmem_dir && sync
        sync && echo 3 > /proc/sys/vm/drop_caches
        $micro_dir/rw_expt read rand 4096 2>&1 | tee -a $fs_results/run$run_id

        rm -rf $pmem_dir/*
        sync && echo 3 > /proc/sys/vm/drop_caches
        $micro_dir/rw_expt write seq 4096 2>&1 | tee -a $fs_results/run$run_id

    fi

    date

}


run_workload

cd $cur_dir
