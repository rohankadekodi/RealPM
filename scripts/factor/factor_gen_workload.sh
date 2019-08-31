#!/bin/bash

set -x

cur_dir=`readlink -f .`
root_dir=`readlink -f ../..`
pmem_dir=/mnt/pmem_emul

mkdir -p $root_dir/factor/workload

sudo dd if=/dev/urandom of=$pmem_dir/test.txt bs=1M count=1024

cd $cur_dir
sudo cp -r $pmem_dir/test.txt $root_dir/factor/workload/

sudo rm $pmem_dir/test.txt
