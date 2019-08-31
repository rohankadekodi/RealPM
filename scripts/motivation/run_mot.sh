#!/bin/bash

cur_dir=`readlink -f ./`
src_dir=`readlink -f ../../`
setup_dir=$src_dir/scripts/configs
pmem_dir=/mnt/pmem_emul

run_mot()
{
    fs=$1
    for run in 1 2 3 4 5 6 7 8 9 10
    do
        sudo rm -rf $pmem_dir/*
        sudo taskset -c 0-7 ./run_fs.sh $fs $run
        sleep 2
    done
}

sudo $setup_dir/dax_config.sh
run_mot dax

sudo $setup_dir/nova_relaxed_config.sh
run_mot relaxed_nova

sudo $setup_dir/pmfs_config.sh
run_mot pmfs

sudo $setup_dir/nova_config.sh
run_mot nova

sudo $setup_dir/dax_config.sh
run_mot boost

sudo $setup_dir/dax_config.sh
run_mot sync_boost

sudo $setup_dir/dax_config.sh
run_mot posix_boost
