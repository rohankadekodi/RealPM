#!/bin/bash

set -x

cur_dir=`readlink -f .`
root_dir=`readlink -f ../..`
worst_dir=$root_dir/worst

cd $worst_dir
gcc micro_worst_workload.c -o worst -O3

cd $cur_dir
