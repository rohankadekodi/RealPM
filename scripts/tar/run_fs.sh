#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: sudo ./run_fs.sh <fs> <run_id>"
    exit 1
fi

set -x

workload=tar
fs=$1
run_id=$2
src_dir=`readlink -f ../../`
cur_dir=`readlink -f ./`
tar_dir=$src_dir/tar
workload_dir=$tar_dir/workload
pmem_dir=/mnt/pmem_emul
boost_dir=$src_dir/splitfs
result_dir=$src_dir/results
fs_results=$result_dir/$fs/$workload
workload_file=tar_workload.tar.gz

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

    echo ----------------------- TAR WORKLOAD ---------------------------

    mkdir -p $fs_results
    rm $fs_results/run$run_id

    rm -rf $pmem_dir/*
    cp -r $workload_dir/$workload_file $pmem_dir && sync

    cd $pmem_dir

    if [ $run_boost -eq 1 ]; then
        export LD_LIBRARY_PATH=$src_dir/splitfs-so/tar/$mode
        export NVP_TREE_FILE=$boost_dir/bin/nvp_nvp.tree
    fi

    sleep 5

    date

    if [ $run_boost -eq 1 ]; then
        ( time LD_PRELOAD=$src_dir/splitfs-so/tar/$mode/libnvp.so $tar_dir/src/tar -xf $pmem_dir/$workload_file ) 2>&1 | tee $fs_results/run$run_id
    else
        ( time $tar_dir/src/tar -xf $pmem_dir/$workload_file ) 2>&1 | tee $fs_results/run$run_id
    fi

    date

    cd $current_dir

    echo Sleeping for 5 seconds . .
    sleep 5

}


run_workload

cd $cur_dir
