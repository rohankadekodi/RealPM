#!/bin/bash

set -x

cur_dir=`readlink -f .`
root_dir=`readlink -f ../..`
micro_dir=$root_dir/micro

cd $micro_dir
gcc rw_experiment.c -o rw_expt -O3

cd $cur_dir
