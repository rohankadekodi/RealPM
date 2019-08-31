#!/bin/bash

cur_dir=`readlink -f ./`
src_dir=`readlink -f ../../`
setup_dir=$src_dir/scripts/configs
pmem_dir=/mnt/pmem_emul

run_micro()
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
run_micro dax

sudo $setup_dir/nova_relaxed_config.sh
run_micro relaxed_nova

sudo $setup_dir/pmfs_config.sh
run_micro pmfs

sudo $setup_dir/nova_config.sh
run_micro nova

sudo $setup_dir/dax_config.sh
run_micro boost

sudo $setup_dir/dax_config.sh
run_micro sync_boost

sudo $setup_dir/dax_config.sh
run_micro posix_boost
