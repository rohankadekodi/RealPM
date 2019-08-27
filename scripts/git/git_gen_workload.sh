#!/bin/bash

set -x

cur_dir=`readlink -f ./`
root_dir=`readlink -f ../..`
pmem_dir=/mnt/pmem_emul
linux_dir=linux-4.18.10

sudo mkdir -p $pmem_dir/repo
sudo cp $root_dir/$linux_dir $pmem_dir/

for i in {1..9}
do
    sudo mkdir $pmem_dir/repo/folder$i
done

for i in {1..9}
do
    sudo cp -r $pmem_dir/$linux_dir $pmem_dir/repo/folder$i/
done

sudo rm -rf $pmem_dir/$linux_dir

cd $cur_dir
sudo mkdir $root_dir/git/workload
sudo cp -r $pmem_dir/repo $root_dir/git/workload/

sudo rm -rf $pmem_dir/*

