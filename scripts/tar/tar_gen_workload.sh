#!/bin/bash

set -x

cur_dir=`readlink -f .`
root_dir=`readlink -f ../..`
pmem_dir=/mnt/pmem_emul
linux_dir=linux-4.18.10
repo_dir=$pmem_dir/repo

sudo mkdir -p $repo_dir

for i in {1..10}
do
    sudo mkdir $repo_dir/folder$i
done

for i in {1..5}
do
    sudo cp -r $root_dir/$linux_dir $repo_dir/folder$i/
done

for i in {6..10}
do
    sudo dd if=/dev/urandom of=$repo_dir/folder$i/temp1.txt bs=1M count=50
    sudo dd if=/dev/urandom of=$repo_dir/folder$i/temp2.txt bs=1M count=50
    sudo dd if=/dev/urandom of=$repo_dir/folder$i/temp3.txt bs=1M count=50
    sudo dd if=/dev/urandom of=$repo_dir/folder$i/temp4.txt bs=1M count=50
    sudo dd if=/dev/urandom of=$repo_dir/folder$i/temp5.txt bs=1M count=50
done

cd $pmem_dir
sudo tar -zcf tar_workload.tar.gz repo

cd $cur_dir
sudo mkdir $root_dir/tar/workload
sudo cp -r $pmem_dir/tar_workload.tar.gz $root_dir/tar/workload/

sudo rm $pmem_dir/tar_workload.tar.gz
