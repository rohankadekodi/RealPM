#!/bin/bash

cur_dir=`readlink -f ./`
src_dir=`readlink -f ../../`
pmem_dir=/mnt/pmem_emul
setup_dir=$src_dir/scripts/configs

run_redis()
{
    fs=$1
    for run in 1 2 3
    do
        sudo rm -rf $pmem_dir/*
        sudo taskset -c 0-7 ./run_fs.sh $fs $run
        sleep 5
    done
}

sudo $setup_dir/dax_config.sh
run_redis dax

sudo $setup_dir/nova_config.sh
run_redis nova

sudo $setup_dir/nova_relaxed_config.sh
run_redis relaxed_nova

sudo $setup_dir/pmfs_config.sh
run_redis pmfs

sudo $setup_dir/dax_config.sh
run_redis boost

sudo $setup_dir/dax_config.sh
run_redis sync_boost

sudo $setup_dir/dax_config.sh
run_redis posix_boost
